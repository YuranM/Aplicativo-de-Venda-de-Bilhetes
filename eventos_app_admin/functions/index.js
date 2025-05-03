// Importações para funções de 2ª Geração
const {onCall} = require("firebase-functions/v2/https");
const {setGlobalOptions} = require("firebase-functions/v2");
const logger = require("firebase-functions/logger");

// Importações para o Admin SDK
const admin = require('firebase-admin');
admin.initializeApp();

// Opcional: Definir a região da função globalmente (se ainda não o fez)
// setGlobalOptions({ region: 'us-central1' }); // Altere para a sua região, ex: 'europe-west1', 'africa-south1'

// Exporta a função verifyTicket usando a sintaxe de 2ª Geração
exports.verifyTicket = onCall(async (request) => {

  // 1. VERIFICAR AUTENTICAÇÃO
  // Garante que a chamada à função vem de um usuário autenticado.
  if (!request.auth) {
    logger.warn('CF ERRO: Chamada não autenticada à verifyTicket.');
    throw new functions.https.HttpsError('unauthenticated', 'Apenas usuários autenticados podem verificar bilhetes.');
  }

  // O UID do usuário autenticado é o adminUid
  const adminUid = request.auth.uid;

  // 2. VERIFICAR PERMISSÕES DE ADMINISTRADOR
  // Obtém o documento do usuário para verificar se ele é um administrador.
  const adminDoc = await admin.firestore().collection('users').doc(adminUid).get();

  if (!adminDoc.exists || !adminDoc.data().isAdmin) {
    logger.warn(`CF ERRO: Acesso negado para o UID ${adminUid}. Não é um administrador ou isAdmin: false.`);
    throw new functions.https.HttpsError('permission-denied', 'Apenas administradores podem verificar bilhetes.');
  }

  // Extrai os dados do payload da requisição
  const ticketId = request.data.ticketId;
  const eventIdBeingManaged = request.data.eventId;

  // 3. VALIDAR ARGUMENTOS DE ENTRADA
  // Garante que o ticketId e eventId foram fornecidos.
  if (!ticketId || !eventIdBeingManaged) {
    logger.error('CF ERRO: ticketId ou eventId são nulos ou vazios na requisição.');
    throw new functions.https.HttpsError('invalid-argument', 'O ID do bilhete e o ID do evento são obrigatórios.');
  }

  // Referência ao documento do bilhete no Firestore
  const ticketRef = admin.firestore().collection('individual_tickets').doc(ticketId);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const ticketDoc = await transaction.get(ticketRef);

      // 4. VERIFICAR EXISTÊNCIA DO BILHETE
      if (!ticketDoc.exists) {
        logger.info(`CF INFO: Bilhete ${ticketId} não encontrado.`);
        return { status: 'invalid', message: 'Bilhete não encontrado.' };
      }

      const ticketData = ticketDoc.data();

      // 5. VERIFICAR SE O BILHETE PERTENCE AO EVENTO CORRETO
      if (ticketData.eventId !== eventIdBeingManaged) {
          logger.info(`CF INFO: Bilhete ${ticketId} pertence ao evento ${ticketData.eventId}, mas a verificação é para ${eventIdBeingManaged}.`);
          return { status: 'invalid', message: 'Este bilhete não pertence a este evento.' };
      }

      // 6. VERIFICAR STATUS DE USO DO BILHETE
      if (ticketData.isUsed === true) {
        logger.info(`CF INFO: Bilhete ${ticketId} já utilizado em ${new Date(ticketData.usedAt.seconds * 1000).toLocaleString()}.`);
        return { status: 'already_used', message: `Bilhete já utilizado em ${new Date(ticketData.usedAt.seconds * 1000).toLocaleString()}.` };
      }

      // 7. MARCAR BILHETE COMO USADO (DENTRO DA TRANSAÇÃO)
      transaction.update(ticketRef, {
        isUsed: true,
        usedAt: admin.firestore.FieldValue.serverTimestamp(),
        usedByAdminId: adminUid // Registra qual admin usou o bilhete
      });

      logger.info(`CF SUCESSO: Bilhete ${ticketId} validado com sucesso por ${adminUid}.`);
      return { status: 'valid', message: 'Bilhete validado com sucesso!', ticketType: ticketData.priceOptionType };
    });
    return result;

  } catch (error) {
    logger.error("CF ERRO: Erro na transação de verificação de bilhete:", error);
    throw new functions.https.HttpsError('internal', 'Erro interno ao verificar o bilhete.', error.message);
  }
});

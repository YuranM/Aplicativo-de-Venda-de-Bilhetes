import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('A senha fornecida é muito fraca.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('O e-mail já está em uso por outra conta.');
      }
      throw Exception(e.message); // Outros erros
    } catch (e) {
      throw Exception('Erro ao tentar se cadastrar: $e');
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Nenhum usuário encontrado para este e-mail.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Senha incorreta para este e-mail.');
      } else if (e.code == 'invalid-credential') {
        throw Exception('Credenciais inválidas. Verifique seu e-mail e senha.');
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro ao tentar fazer login: $e');
    }
  }

  // Método para fazer logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get user {
    return _auth.authStateChanges();
  }
}
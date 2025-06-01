import 'package:bilheteriapdm/widgets/produtos/produto_widget.dart';
import 'package:bilheteriapdm/widgets/title_text.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../services/assets_manager.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  late TextEditingController searchTextController;
  @override
  void initState() {
    searchTextController = TextEditingController();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const TitleText(label: "Pesquisar produtos"),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(AssetsManager.shoppingCart),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                controller: searchTextController,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                      IconlyLight.search,
                  ),
                  suffixIcon: IconButton(
                      onPressed: (){
                        setState(() {
                          searchTextController.clear();
                          FocusScope.of(context).unfocus();
                        });
                      },
                      icon: const Icon(
                         IconlyLight.closeSquare,
                      color: Colors.red,
                      ),
                  ),
                ),
                onFieldSubmitted: (value) {
                  print(searchTextController.text);
                },
              ),
              Expanded(
                child: DynamicHeightGridView(
                    builder: (context, index){
                      return ProdutoWidget();
                    },
                    itemCount: 30,
                    crossAxisCount: 2,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

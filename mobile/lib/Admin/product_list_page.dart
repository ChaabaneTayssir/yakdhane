import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:image_picker/image_picker.dart';

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<dynamic> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:9991/produits/populaires'));
    if (response.statusCode == 200) {
      setState(() {
        _products = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération des produits')),
      );
    }
  }

  Future<void> _deleteProduct(String productId, String productName) async {
    final response = await http.delete(Uri.parse('http://10.0.2.2:9991/produits/$productId'));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produit "$productName" supprimé avec succès !')),
      );
      _fetchProducts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la suppression du produit')),
      );
    }
  }



  Future<void> _showEditProductDialog(Map<String, dynamic> product) async {
    final _nameController = TextEditingController(text: product['nom']);
    final _priceController = TextEditingController(text: product['prix'].toString());
    final _descriptionController = TextEditingController(text: product['description'].toString());
    final _imagepathController = TextEditingController();
    final _quantiteController = TextEditingController(text: product['quantite'].toString());

    final ImagePicker picker = ImagePicker();
    XFile? pickedFile;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier le produit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nom du produit'),
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Prix du produit'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _quantiteController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantité'),
            ),
            // Bouton pour choisir une nouvelle image
            ElevatedButton(
              onPressed: () async {
                pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  _imagepathController.text = pickedFile!.path;
                }
              },
              child: Text('Choisir une image'),
            ),
            if (_imagepathController.text.isNotEmpty) ...[
              SizedBox(height: 10),
              Text('Image sélectionnée : ${_imagepathController.text}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final updatedProduct = {
                'nom': _nameController.text,
                'prix': double.tryParse(_priceController.text) ?? product['prix'],
                'description': _descriptionController.text,
                'quantite': int.tryParse(_quantiteController.text) ?? product['quantite'],
                'image_path': _imagepathController.text,
                'categorie': {
                  'id': product['categorie']['id'], // Assurez-vous que cet ID est correct et transmis
                }
              };


              final response = await http.put(
                Uri.parse('http://10.0.2.2:9991/produits/update/${product['id']}'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(updatedProduct),
              );

              if (response.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Produit mis à jour avec succès !')),
                );
                _fetchProducts();
              } else {
                print('Response status: ${response.statusCode}');
                print('Response body: ${response.body}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Échec de la mise à jour du produit : ${response.body}')),
                );
              }

              Navigator.pop(context);
            },
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Produits'),
      ),
      body: _products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(product['nom']),
              subtitle: Text('Prix: ${product['prix']} €'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _showEditProductDialog(product),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirmation de suppression'),
                          content: Text('Voulez-vous vraiment supprimer "${product['nom']}" ?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteProduct(product['id'].toString(), product['nom']);
                              },
                              child: Text('Supprimer'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

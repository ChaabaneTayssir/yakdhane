import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion des catégories',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CategoryFormScreen(),
    );
  }
}

class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({super.key});

  @override
  _CategoryFormScreenState createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? nom;

  Future<void> addCategory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:9991/produits/categorie/ajouter'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'nom': nom}),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Catégorie ajoutée avec succès!')),
          );
          _formKey.currentState!.reset();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de l\'ajout de la catégorie')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de connexion avec le serveur')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter une catégorie"),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryListScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Nom de la catégorie",
                  hintText: "Entrez le nom de la catégorie",
                ),
                onSaved: (newValue) => nom = newValue,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Le nom de la catégorie est requis";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addCategory,
                child: const Text("Ajouter la catégorie"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  List<dynamic> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:9991/produits/categories'),
      );

      if (response.statusCode == 200) {
        setState(() {
          categories = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du chargement des catégories')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de connexion avec le serveur')),
      );
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      // Construire l'URL avec le paramètre "id"
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:9991/produits/categories/supprimer?id=$id'),
      );

      if (response.statusCode == 200) {
        setState(() {
          // Supprimer la catégorie en fonction de l'ID
          categories.removeWhere((category) => category['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Catégorie avec ID "$id" supprimée avec succès!')),
        );
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${response.body}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur inconnue lors de la suppression.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de connexion avec le serveur')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des catégories"),
      ),
      body: categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            title: Text(category['nom']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditCategoryScreen(category: category),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => deleteCategory(category['id']),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class EditCategoryScreen extends StatefulWidget {
  final dynamic category;

  const EditCategoryScreen({Key? key, required this.category}) : super(key: key);

  @override
  _EditCategoryScreenState createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? id;
  String? nom;
  String? nouveauNom;
  String? ancienNom;

  @override
  void initState() {
    super.initState();
    print(widget.category); // Vérification des données
    id = widget.category['id'].toString();
    nom = widget.category['nom'];
    ancienNom = nom; // Initialisation correcte
  }

  Future<void> updateCategory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        print('ancienNom: $ancienNom, nouveauNom: $nouveauNom'); // Log des données
        final response = await http.put(
          Uri.parse('http://10.0.2.2:9991/produits/modifier'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'ancienNom': ancienNom, 'nouveauNom': nouveauNom}),
        );

        print('Status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Catégorie mise à jour avec succès!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la mise à jour de la catégorie')),
          );
        }
      } catch (e) {
        print('Erreur: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de connexion avec le serveur')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier la catégorie"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: nom,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: "Nom actuel de la catégorie",
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Nouveau nom de la catégorie",
                ),
                onSaved: (newValue) => nouveauNom = newValue,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Le nouveau nom est requis";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateCategory,
                child: const Text("Mettre à jour"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

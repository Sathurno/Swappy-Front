import 'package:flutter/material.dart';
import 'profile.dart';
import 'log_in.dart';
import 'virtual_closet.dart';
import 'add_product.dart';
import 'chat.dart';
import '/Services/catalogue.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Catalogue extends StatefulWidget {
  const Catalogue({Key? key}) : super(key: key);

  @override
  _CatalogueState createState() => _CatalogueState();
}

class _CatalogueState extends State<Catalogue> {
  int _selectedIndex = 0;
  String _selectedCategory = 'Todos';
  String _searchQuery = '';
  List<Map<String, dynamic>> catalogoRopa = [];
  bool _isLoading = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final CatalogService _catalogService = CatalogService();

  final List<String> categorias = [
    'Todos',
    'Camisetas',
    'Vestidos',
    'Pantalones',
    'Zapatos',
    'Faldas',
    'Chaquetas',
    'Accesorios',
  ];

  @override
  void initState() {
    super.initState();
    _loadClothes();
  }

  Future<void> _loadClothes() async {
    setState(() {
      _isLoading = true;
    });
    List<Map<String, dynamic>> clothes = await _catalogService.getClothes();
    setState(() {
      catalogoRopa = clothes;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get filteredCatalogo {
    return catalogoRopa.where((item) {
      final matchesCategory = _selectedCategory == 'Todos' ||
          item['categoria'] == _selectedCategory;
      final matchesSearch = item['nombre']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          item['etiquetas'].any(
              (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('../../assets/swappy.png', height: 30),
            SizedBox(width: 10),
            Text('Catálogo', style: TextStyle(color: Colors.black)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Pantalla de favoritos no implementada')),
              );
            },
          ),
          (_auth.currentUser != null)
              ? IconButton(
                  icon: Icon(Icons.person, color: Colors.black),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Profile()),
                    );
                  },
                )
              : TextButton(
                  child: Text('Iniciar sesión',
                      style: TextStyle(color: Colors.black)),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.black),
            onPressed: () {
              if (_auth.currentUser != null) {
                // Usuario autenticado, ir a la página de añadir producto
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddProduct()),
                );
              } else {
                // Usuario no autenticado, ir a la página de inicio de sesión
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                ).then((value) {
                  // Cuando se vuelve de la página de inicio de sesión, verificar si el usuario se autenticó
                  if (_auth.currentUser != null) {
                    // Si se autenticó, ir a la página de añadir producto
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddProduct()),
                    );
                  }
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Busca ropa para intercambiar',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(width: 16),
                for (String categoria in categorias)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(categoria),
                      selected: _selectedCategory == categoria,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = categoria;
                        });
                      },
                      selectedColor: Colors.teal.shade100,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                SizedBox(width: 8),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : CatalogueGrid(filteredCatalogo: filteredCatalogo),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Catalogue()),
          );
        },
        label: Text('Intercambiar'),
        icon: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Armario Virtual',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              // Ya estamos en la página del catálogo
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VirtualCloset()),
              );
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MessagingPage()),
              );
          }
        },
      ),
    );
  }
}

class CatalogueGrid extends StatelessWidget {
  final List<Map<String, dynamic>> filteredCatalogo;

  const CatalogueGrid({Key? key, required this.filteredCatalogo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth = constraints.maxWidth / 5;
        final double aspectRatio = itemWidth / (itemWidth * 1.5);

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: itemWidth,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: filteredCatalogo.length,
          itemBuilder: (context, index) {
            final item = filteredCatalogo[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.asset(
                        item['imagen'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['nombre'],
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${item['precio']}€',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.teal),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

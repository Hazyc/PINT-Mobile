import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  final File? bannerImage;
  final File? avatarImage;
  final String userName;
  final String userDescription;
  final Function(File?, File?, String, String) onSave;

  EditProfilePage({
    required this.bannerImage,
    required this.avatarImage,
    required this.userName,
    required this.userDescription,
    required this.onSave,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _bannerImage;
  File? _avatarImage;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _bannerImage = widget.bannerImage;
    _avatarImage = widget.avatarImage;
    _nameController = TextEditingController(text: widget.userName);
    _descriptionController = TextEditingController(text: widget.userDescription);
  }

  Future<void> _pickImage(ImageSource source, bool isBanner) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          if (isBanner) {
            _bannerImage = File(pickedFile.path);
          } else {
            _avatarImage = File(pickedFile.path);
          }
        });
      } else {
        print("Nenhuma imagem selecionada.");
      }
    } catch (e) {
      print("Erro ao pegar imagem: $e");
    }
  }

  void _showImageSourceDialog(bool isBanner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isBanner ? 'Alterar Foto de Capa' : 'Alterar Foto de Perfil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Escolher da Galeria'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery, isBanner);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Tirar uma Foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera, isBanner);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Editar Perfil',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0DCAF0),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              widget.onSave(_bannerImage, _avatarImage, _nameController.text, _descriptionController.text);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () => _showImageSourceDialog(true),
                  child: _bannerImage != null
                      ? Image.file(
                          _bannerImage!,
                          width: double.infinity,
                          height: 150.0,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          'https://static.todamateria.com.br/upload/pa/is/paisagem-natural-og.jpg',
                          width: double.infinity,
                          height: 150.0,
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  top: 70.0, // Puxando o avatar mais para cima
                  left: MediaQuery.of(context).size.width / 2 - 75,
                  child: GestureDetector(
                    onTap: () => _showImageSourceDialog(false),
                    child: CircleAvatar(
                      radius: 75.0, // Tamanho do avatar
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _avatarImage != null
                          ? FileImage(_avatarImage!)
                          : AssetImage('assets/images/placeholder_image.png') as ImageProvider,
                      child: _avatarImage == null
                          ? Icon(
                              Icons.camera_alt,
                              color: Colors.grey[800],
                              size: 50.0,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 100.0), // Ajuste o espaço aqui conforme necessário
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nome'),
                  ),
                  SizedBox(height: 20.0),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Descrição'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
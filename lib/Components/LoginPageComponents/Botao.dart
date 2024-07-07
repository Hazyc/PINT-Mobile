import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String buttonText;
  final IconData? leadingIcon; // Adicionando o ícone como um parâmetro opcional

  const MyButton({
    Key? key,
    required this.onTap,
    required this.buttonText,
    this.leadingIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15), // Ajusta o padding vertical
        margin: const EdgeInsets.symmetric(horizontal: 25.0), // Ajusta o padding horizontal
        width: double.infinity, // Define a largura do botão para preencher o contêiner pai
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Garante que o tamanho do Row se ajuste ao conteúdo
            children: [
              if (leadingIcon != null) // Verifica se o ícone é fornecido
                Icon(
                  leadingIcon,
                  color: Colors.white,
                ),
              if (leadingIcon != null) // Adiciona um espaço entre o ícone e o texto
                SizedBox(width: 8),
              Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}






class Campo{

  int id_campo = 0;
  String tipo_campo = "";
  String nome_campo = "";
  bool required_campo = false;
  bool novo = false;  //usado para o edit formulario



Campo({

  required this.id_campo,
  required this.tipo_campo,
  required this.nome_campo,
  required this.required_campo,
  required this.novo,

});



factory Campo.fromJson(Map<String, dynamic> json) {
    return Campo(
      id_campo: json['ID_CAMPO'] ?? 0,
      tipo_campo: json['TIPO_CAMPO'] ?? '',
      nome_campo: json['NOME_CAMPO'] ?? '',
      required_campo: json['REQUIRED_CAMPO'] ?? false,
      novo: json['NOVO'] ?? false, //nao vem do banco, mas precisa de estar aqui senao dá erro
    );
  }

}
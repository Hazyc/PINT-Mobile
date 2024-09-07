




class Campo{

  int id_campo = 0;
  String tipo_campo = "";
  String nome_campo = "";
  bool required_campo = false;



Campo({

  required this.id_campo,
  required this.tipo_campo,
  required this.nome_campo,
  required this.required_campo,

});



factory Campo.fromJson(Map<String, dynamic> json) {
    return Campo(
      id_campo: json['ID_CAMPO'] ?? 0,
      tipo_campo: json['TIPO_CAMPO'] ?? '',
      nome_campo: json['NOME_CAMPO'] ?? '',
      required_campo: json['REQUIRED_CAMPO'] ?? false,
    );
  }

}
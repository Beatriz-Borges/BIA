// import 'package:bia/models/pergunta_list.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'custom_button.dart';

// class SearchCardPergunta extends StatefulWidget {
//   const SearchCardPergunta({super.key});

//   @override
//   State<SearchCardPergunta> createState() => _SearchCardPerguntaState();
// }

// class _SearchCardPerguntaState extends State<SearchCardPergunta> {
//   final searchController = TextEditingController();

//   // bool _expanded = false;
//   bool alfabetico = false;

//   @override
//   Widget build(BuildContext context) {
//     final PerguntaList perguntaList = Provider.of<PerguntaList>(context);

//     return SizedBox(
//       // height: _expanded ? availableHeight * 0.35 : availableHeight * 0.25,
//       // height: _expanded ? 170 : 160,
//       height: 160,
//       child: Card(
//         // margin: const EdgeInsets.all(15),
//         shape: RoundedRectangleBorder(
//             side: const BorderSide(
//               color: Colors.grey,
//             ),
//             borderRadius: BorderRadius.circular(10)),
//         // elevation: 15,
//         color: Colors.white,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             // if (!_expanded)
//             Padding(
//               padding: const EdgeInsets.only(
//                 left: 8,
//                 right: 8,
//                 top: 8,
//               ),
//               child: TextField(
//                 controller: searchController,
//                 decoration: InputDecoration(
//                   hintText: 'Pesquisar Pergunta',
//                   hintStyle: const TextStyle(
//                     color: Colors.grey,
//                   ),
//                   prefixIcon: const Icon(Icons.search),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     gapPadding: 10,
//                   ),
//                 ),
//               ),
//             ),
//             // if (_expanded)
//             //   Padding(
//             //     padding: const EdgeInsets.symmetric(
//             //       horizontal: 10,
//             //     ),
//             //     child: Padding(
//             //       padding: const EdgeInsets.symmetric(horizontal: 5),
//             //       child: Column(
//             //         crossAxisAlignment: CrossAxisAlignment.start,
//             //         children: [
//             //           const Text(
//             //             'Ordenação de perguntas',
//             //             textAlign: TextAlign.start,
//             //             style: TextStyle(
//             //               color: Colors.grey,
//             //               fontWeight: FontWeight.bold,
//             //               fontSize: 17,
//             //             ),
//             //           ),
//             //           Row(
//             //             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             //             children: [
//             //               Column(
//             //                 children: [
//             //                   Checkbox(
//             //                     value: alfabetico,
//             //                     onChanged: (value) {
//             //                       setState(() {
//             //                         alfabetico = value ?? true;
//             //                       });
//             //                     },
//             //                   ),
//             //                   const Text(
//             //                     'Alfabética',
//             //                     style: TextStyle(
//             //                       color: Colors.grey,
//             //                     ),
//             //                   ),
//             //                 ],
//             //               ),
//             //             ],
//             //           ),
//             //         ],
//             //       ),
//             //     ),
//             //   ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 30),
//                   child: CustomButton(
//                     onPressed: () {
//                       perguntaList.filterItems(
//                         perguntaTitle: searchController.text.toUpperCase(),
//                         alfabetico: alfabetico,
//                       );
//                     },
//                     child: const Text('Buscar'),
//                     // child: Text(_expanded ? 'Filtrar' : 'Buscar'),
//                   ),
//                 ),
//                 // CustomButton(
//                 //   onPressed: () {
//                 //     setState(() {
//                 //       _expanded = !_expanded;
//                 //     });
//                 //   },
//                 //   child: Text(_expanded ? 'Voltar' : 'Aplicar Filtros'),
//                 // ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

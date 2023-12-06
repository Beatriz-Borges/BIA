import 'package:flutter/material.dart';

// a customized widget for the cards

class CardComponent extends StatefulWidget {
  final String titulo;
  final Color tituloColor;
  final double cardSize;
  final List<Widget> children;
  final Key? tileKey;
  final Function()? onDelete;
  final Function()? onEdit;

  const CardComponent({
    required this.titulo,
    this.tituloColor = Colors.grey,
    required this.cardSize,
    required this.children,
    this.tileKey,
    this.onDelete,
    this.onEdit,
    super.key,
  });

  @override
  State<CardComponent> createState() => _CardComponentState();
}

class _CardComponentState extends State<CardComponent> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ListTile(
            key: widget.tileKey,
            title: Text(
              widget.titulo,
              style: TextStyle(
                color: widget.tituloColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: SizedBox(
              width: 90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.onDelete != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: InkWell(
                        onTap: widget.onDelete,
                        child: Icon(
                          Icons.delete,
                          size: 20.0,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  if (widget.onEdit != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: InkWell(
                        onTap: widget.onEdit,
                        child: Icon(
                          Icons.edit,
                          size: 20.0,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: InkWell(
                      child: Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 20.0,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        setState(() {
                          // alternates between showing or hiding the rest of
                          // the info
                          _expanded = !_expanded;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Container with an animation to change it's size
          AnimatedContainer(
            duration: const Duration(microseconds: 300),
            height: _expanded ? widget.cardSize : 0,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(
                      height: 1,
                    ),
                    ...widget.children,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

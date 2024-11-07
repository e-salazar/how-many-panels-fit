import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:how_many_panels_fit/enums/orientation.dart' as enums;
import 'package:how_many_panels_fit/models/cell.dart' as models;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('¿Cuántos paneles caben?')),
        body: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 32),
          child: MainScreen(),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Random _random = Random();
  Color getRandomColor() {
    return Color.fromARGB(
      255,
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
    );
  }

  int totalColumns = 3;
  int totalRows = 3;
  int panelColumnsSize = 2;
  int panelRowsSize = 3;
  List<List<models.Cell>> grid = [];

  @override
  Widget build(BuildContext context) {
    int panelsCount = _placePanels();

    return Column(
      children: [
        Container(
          color: Colors.blueGrey[100],
          child: Column(
            children: [
              const Text('Tamaño del techo', style: TextStyle(fontSize: 18)),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text('Ancho', style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove), // Icono del botón
                            onPressed: () => totalColumns > 1 ? setState(() =>  totalColumns--) : null,
                          ),
                          Text('$totalColumns'),
                          IconButton(
                            icon: const Icon(Icons.add), // Icono del botón
                            onPressed: () => setState(() => totalColumns++),
                          ),
                        ],
                      )
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Alto', style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove), // Icono del botón
                            onPressed: () => totalRows > 1 ? setState(() =>  totalRows--) : null,
                          ),
                          Text('$totalRows'),
                          IconButton(
                            icon: const Icon(Icons.add), // Icono del botón
                            onPressed: () => setState(() => totalRows++),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          color: Colors.blueGrey[50],
          child: Column(
            children: [
              const Text('Tamaño del panel', style: TextStyle(fontSize: 18)),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text('Ancho', style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove), // Icono del botón
                            onPressed: () => panelColumnsSize > 1 ? setState(() =>  panelColumnsSize--) : null,
                          ),
                          Text('$panelColumnsSize'),
                          IconButton(
                            icon: const Icon(Icons.add), // Icono del botón
                            onPressed: () => setState(() => panelColumnsSize++),
                          ),
                        ],
                      )
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Alto', style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove), // Icono del botón
                            onPressed: () => panelRowsSize > 1 ? setState(() =>  panelRowsSize--) : null,
                          ),
                          Text('$panelRowsSize'),
                          IconButton(
                            icon: const Icon(Icons.add), // Icono del botón
                            onPressed: () => setState(() => panelRowsSize++),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _drawGrid(),
        ),
        Text('Total de paneles: $panelsCount', style: const TextStyle(fontSize: 22)),
      ],
    );
  }

  Widget _drawGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: totalColumns,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: totalColumns * totalRows,
      itemBuilder: (BuildContext context, int index) {
        models.Cell cell = grid[index % totalColumns][(index ~/ totalColumns)];
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: cell.isUsed ? cell.color : Colors.grey),
            color: cell.color,
          ),
        );
      },
    );
  }

  void setCellAsUsed(int column, int row, Color color) {
    grid[column][row].isUsed = true;
    grid[column][row].color = color;
  }

  bool _placePanel(int columnPosition, int rowPosition, int columnsSize, int rowsSize) {
    if (!_canPlacePanel(columnPosition, rowPosition, columnsSize, rowsSize)) {
      return false;
    }

    Color color = getRandomColor();
    for (var i = columnPosition; i < columnPosition + columnsSize; i++) {
      for (var j = rowPosition; j < rowPosition + rowsSize; j++) {
        setCellAsUsed(i, j, color);
      }
    }

    return true;
  }
  bool _canPlacePanel(int columnPosition, int rowPosition, int columnsSize, int rowsSize) {
    if (columnPosition + columnsSize > totalColumns) {
      return false;
    }
    if (rowPosition + rowsSize > totalRows) {
      return false;
    }

    for (var i = columnPosition; i < columnPosition + columnsSize; i++) {
      for (var j = rowPosition; j < rowPosition + rowsSize; j++) {
        if (grid[i][j].isUsed) {
          return false;
        }
      }
    }
    return true;
  }
  
  int _placePanels() {
    grid = List.generate(totalColumns, (int i) => List.generate(totalRows, (int j) => models.Cell()));
    int headColumn = 0;
    int headRow = 0;

    int maxPanelSize = max(panelColumnsSize, panelRowsSize);
    int minPanelSize = min(panelColumnsSize, panelRowsSize);

    int panelsCount = 0;

    while (true) {
      print('------------------------------------------------');
      print('Head in ($headColumn, $headRow)');

      if (headColumn >= totalColumns && headRow >= totalRows) {
        print('Head out of both bounds ($headColumn, $headRow)');
        print('Finished');
        break;
      }
      
      if (headColumn >= totalColumns) {
          print('Head out of horizontal bound ($headColumn, $headRow)');
          headColumn = 0;
          headRow++;
          print('Head moved to ($headColumn, $headRow)');
          continue;
      }

      enums.Orientation? bestPosition = _getBestPosition(headColumn, headRow, maxPanelSize, minPanelSize);
      
      if (bestPosition == null) {
        print('Horizontal movement (+1)');
        headColumn++;
        print('Head moved to ($headColumn, $headRow)');
        continue;
      }

      if (bestPosition == enums.Orientation.horizontal) {
        if (_placePanel(headColumn, headRow, maxPanelSize, minPanelSize)) {
          print('Placed in ($headColumn, $headRow) with size ($maxPanelSize, $minPanelSize) (horizontally)');
          panelsCount++;
          print('Horizontal movement (+$maxPanelSize)');
          headColumn += maxPanelSize;
        } else {
          print('FATAL: Cant be placed in ($headColumn, $headRow) with size ($maxPanelSize, $minPanelSize) (horizontally)');
          exit(-1);
        }
      } else {
        if (_placePanel(headColumn, headRow, minPanelSize, maxPanelSize)) {
          print('Placed in ($headColumn, $headRow) with size ($minPanelSize, $maxPanelSize) (vertically)');
          panelsCount++;
          print('Horizontal movement (+$minPanelSize)');
          headColumn += minPanelSize;
        } else {
          print('FATAL: Cant be placed in ($headColumn, $headRow) with size ($minPanelSize, $maxPanelSize) (vertically)');
          exit(-1);
        }
      }

      print('Head moved to ($headColumn, $headRow)');
    }
    return panelsCount;
  }
  
  enums.Orientation? _getBestPosition(int headColumn, int headRow, int maxPanelSize, int minPanelSize) {
    int remainingColumns = totalColumns - headColumn;
    int remainingRows = totalRows - headRow;
    bool canBePlacedHorizontally = _canPlacePanel(headColumn, headRow, maxPanelSize, minPanelSize);
    bool canBePlacedVertically = _canPlacePanel(headColumn, headRow, minPanelSize, maxPanelSize);
    
    if (canBePlacedHorizontally && canBePlacedVertically) {
      print('Can be placed in any position. Finding most efficient.');
      
      if (remainingRows == maxPanelSize) {
        return enums.Orientation.vertical;
      } else if (remainingRows == minPanelSize) {
        return enums.Orientation.horizontal;
      } else if (remainingColumns == maxPanelSize) {
        return enums.Orientation.horizontal;
      } else if (remainingColumns == minPanelSize) {
        return enums.Orientation.vertical;
      } else if (remainingColumns % maxPanelSize == 0) { //Es múltiplo del lado grande del panel
        return enums.Orientation.horizontal;
      } else if (remainingColumns % minPanelSize == 0) { //Es múltiplo del lado pequeño del panel
        return enums.Orientation.vertical;
      }

      return enums.Orientation.horizontal;
    } else if (canBePlacedHorizontally) {
      print('Can be only placed horizontally.');
      return enums.Orientation.horizontal;
    } else if (canBePlacedVertically) {
      print('Can be only placed vertically.');
      return enums.Orientation.vertical;
    } else {
      print('Cannot be placed in any way');
      return null;
    }
  }
}

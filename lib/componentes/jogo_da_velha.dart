import 'dart:math';
import 'package:flutter/material.dart';

class JogoDaVelha extends StatefulWidget {
  const JogoDaVelha({super.key});

  @override
  State<JogoDaVelha> createState() => _JogoDaVelhaState();
}

class _JogoDaVelhaState extends State<JogoDaVelha> {
  List<String> _tabuleiro = List.filled(9, '');
  String _jogadorAtual = 'X';
  bool _jogandoContraComputador = false;
  final Random _random = Random();
  bool _computadorPensando = false;

  void _reiniciarJogo() {
    setState(() {
      _tabuleiro = List.filled(9, '');
      _jogadorAtual = 'X';
      _computadorPensando = false;
    });
  }

  void _alternarJogador() {
    setState(() {
      _jogadorAtual = _jogadorAtual == 'X' ? 'O' : 'X';
    });
  }

  void _exibirDialogoResultado(String resultado) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(resultado == 'Empate' ? 'Empate!' : 'Vencedor: $resultado'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _reiniciarJogo();
              },
              child: const Text('Reiniciar Jogo'),
            ),
          ],
        );
      },
    );
  }

  bool _verificarVitoria(String jogador) {
    const combinacoesVencedoras = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var combinacao in combinacoesVencedoras) {
      if (_tabuleiro[combinacao[0]] == jogador &&
          _tabuleiro[combinacao[1]] == jogador &&
          _tabuleiro[combinacao[2]] == jogador) {
        return true;
      }
    }
    return false;
  }

  void _verificarFimDeJogo() {
    if (_verificarVitoria('X')) {
      _exibirDialogoResultado('X');
    } else if (_verificarVitoria('O')) {
      _exibirDialogoResultado('O');
    } else if (!_tabuleiro.contains('')) {
      _exibirDialogoResultado('Empate');
    }
  }

  void _jogadaComputador() {
    setState(() => _computadorPensando = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      int melhorMovimento = _encontrarMelhorMovimento();
      setState(() {
        _tabuleiro[melhorMovimento] = 'O';
        _computadorPensando = false;
        _verificarFimDeJogo();
        if (!_verificarVitoria('O')) {
          _alternarJogador();
        }
      });
    });
  }

  int _encontrarMelhorMovimento() {
    // Estratégia: priorizar vitória, bloquear adversário, ou jogar no centro.
    for (int i = 0; i < _tabuleiro.length; i++) {
      if (_tabuleiro[i] == '') {
        // Verifica se o computador pode vencer.
        _tabuleiro[i] = 'O';
        if (_verificarVitoria('O')) {
          _tabuleiro[i] = '';
          return i;
        }
        _tabuleiro[i] = '';
      }
    }

    for (int i = 0; i < _tabuleiro.length; i++) {
      if (_tabuleiro[i] == '') {
        // Bloqueia vitória do jogador adversário.
        _tabuleiro[i] = 'X';
        if (_verificarVitoria('X')) {
          _tabuleiro[i] = '';
          return i;
        }
        _tabuleiro[i] = '';
      }
    }

    // Prioriza o centro.
    if (_tabuleiro[4] == '') {
      return 4;
    }

    // Joga nas bordas disponíveis.
    final bordas = [0, 2, 6, 8];
    for (var borda in bordas) {
      if (_tabuleiro[borda] == '') {
        return borda;
      }
    }

    // Joga nas laterais disponíveis.
    final laterais = [1, 3, 5, 7];
    for (var lateral in laterais) {
      if (_tabuleiro[lateral] == '') {
        return lateral;
      }
    }

    return _random.nextInt(9); // Fallback.
  }

  void _realizarJogada(int index) {
    if (_tabuleiro[index] == '' && !_computadorPensando) {
      setState(() {
        _tabuleiro[index] = _jogadorAtual;
        _verificarFimDeJogo();
        if (!_verificarVitoria(_jogadorAtual)) {
          _alternarJogador();
          if (_jogandoContraComputador && _jogadorAtual == 'O') {
            _jogadaComputador();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double tamanhoTabuleiro = MediaQuery.of(context).size.height * 0.5;

    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Modo: ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: _jogandoContraComputador,
                  onChanged: (value) {
                    setState(() {
                      _jogandoContraComputador = value;
                      _reiniciarJogo();
                    });
                  },
                ),
                Text(
                  _jogandoContraComputador ? 'Computador' : 'Humano',
                  style: const TextStyle(fontSize: 16),
                ),
                if (_computadorPensando)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 8,
          child: SizedBox(
            width: tamanhoTabuleiro,
            height: tamanhoTabuleiro,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _realizarJogada(index),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple.shade300, Colors.purple.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(4, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _tabuleiro[index],
                        style: const TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _reiniciarJogo,
          child: const Text('Reiniciar Jogo'),
        ),
      ],
    );
  }
}

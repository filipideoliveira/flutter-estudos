import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const SeguroApp());
}

class SeguroApp extends StatelessWidget {
  const SeguroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Seguro Fácil',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CotacaoScreen(),
    );
  }
}

class CotacaoScreen extends StatefulWidget {
  const CotacaoScreen({super.key});

  @override
  State<CotacaoScreen> createState() => _CotacaoScreenState();
}

class _CotacaoScreenState extends State<CotacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _modeloController = TextEditingController();

  String _tipoVeiculo = 'Carro';

  double _valorVeiculo = 50000;

  bool _coberturaRoubo = false;
  bool _coberturaTerceiros = false;
  bool _coberturaVidros = false;

  bool _assistencia24h = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _modeloController.dispose();

    super.dispose();
  }

  double calcularSeguro() {
    double taxa;

    switch (_tipoVeiculo) {
      case 'Moto':
        taxa = 0.018;
        break;

      case 'Caminhão':
        taxa = 0.035;
        break;

      default:
        taxa = 0.025;
    }

    double total = _valorVeiculo * taxa;

    if (_coberturaRoubo) {
      total += 300;
    }

    if (_coberturaTerceiros) {
      total += 250;
    }

    if (_coberturaVidros) {
      total += 150;
    }

    if (_assistencia24h) {
      total += 180;
    }

    return total;
  }

  void novaCotacao() {
    setState(() {
      _nomeController.clear();
      _modeloController.clear();

      _tipoVeiculo = 'Carro';
      _valorVeiculo = 50000;

      _coberturaRoubo = false;
      _coberturaTerceiros = false;
      _coberturaVidros = false;

      _assistencia24h = false;
    });
  }

  void enviarCotacao() {
    final formValido = _formKey.currentState!.validate();

    if (!formValido) {
      return;
    }

    mostrarConfirmacao();
  }

  void mostrarConfirmacao() {
    final valorSeguro = calcularSeguro();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enviar cotação?'),
          content: Text(
            'Cliente: ${_nomeController.text}\n'
            'Veículo: ${_modeloController.text}\n'
            'Tipo: $_tipoVeiculo\n'
            'Valor do seguro: R\$ ${valorSeguro.toStringAsFixed(2)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cotação enviada com sucesso!')),
                );
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  String criarMensagem() {
    final valorSeguro = calcularSeguro();

    return '''
Olá! Gostaria de solicitar esta cotação de seguro.

Cliente: ${_nomeController.text}
Veículo: ${_modeloController.text}
Tipo: $_tipoVeiculo
Valor do veículo: R\$ ${_valorVeiculo.toStringAsFixed(2)}

Coberturas:
- Roubo e furto: ${_coberturaRoubo ? 'Sim' : 'Não'}
- Danos a terceiros: ${_coberturaTerceiros ? 'Sim' : 'Não'}
- Proteção de vidros: ${_coberturaVidros ? 'Sim' : 'Não'}
- Assistência 24h: ${_assistencia24h ? 'Sim' : 'Não'}

Valor estimado do seguro:
R\$ ${valorSeguro.toStringAsFixed(2)} por ano.
''';
  }
  
  Future<void> enviarWhatsApp() async {
    const telefone = '5511961770865';

    final mensagem = criarMensagem();

    final uri = Uri.https('wa.me', '/$telefone', {'text': mensagem});

    final abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!abriu && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final valorSeguro = calcularSeguro();

    return Scaffold(
      appBar: AppBar(title: const Text('Cotação de Seguro')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dados da cotação',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome do cliente',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o nome do cliente';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _modeloController,
                        decoration: const InputDecoration(
                          labelText: 'Modelo do veículo',
                          hintText: 'Ex.: Honda Civic',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.directions_car),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o modelo do veículo';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Tipo de veículo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      RadioGroup<String>(
                        groupValue: _tipoVeiculo,
                        onChanged: (value) {
                          setState(() {
                            _tipoVeiculo = value!;
                          });
                        },
                        child: const Column(
                          children: [
                            RadioListTile<String>(
                              title: Text('Moto'),
                              secondary: Icon(Icons.two_wheeler),
                              value: 'Moto',
                            ),
                            RadioListTile<String>(
                              title: Text('Carro'),
                              secondary: Icon(Icons.directions_car),
                              value: 'Carro',
                            ),
                            RadioListTile<String>(
                              title: Text('Caminhão'),
                              secondary: Icon(Icons.local_shipping),
                              value: 'Caminhão',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Valor do veículo: R\$ ${_valorVeiculo.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Slider(
                        value: _valorVeiculo,
                        min: 10000,
                        max: 300000,
                        divisions: 29,
                        label: 'R\$ ${_valorVeiculo.toStringAsFixed(0)}',
                        onChanged: (value) {
                          setState(() {
                            _valorVeiculo = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Coberturas adicionais',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CheckboxListTile(
                        title: const Text('Roubo e furto'),
                        subtitle: const Text('+ R\$ 300,00'),
                        value: _coberturaRoubo,
                        onChanged: (value) {
                          setState(() {
                            _coberturaRoubo = value ?? false;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Danos a terceiros'),
                        subtitle: const Text('+ R\$ 250,00'),
                        value: _coberturaTerceiros,
                        onChanged: (value) {
                          setState(() {
                            _coberturaTerceiros = value ?? false;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Proteção de vidros'),
                        subtitle: const Text('+ R\$ 150,00'),
                        value: _coberturaVidros,
                        onChanged: (value) {
                          setState(() {
                            _coberturaVidros = value ?? false;
                          });
                        },
                      ),
                      const SizedBox(height: 8),

                      SwitchListTile(
                        title: const Text('Assistência 24 horas'),
                        subtitle: const Text(
                          'Guincho, pane elétrica e suporte emergencial',
                        ),
                        secondary: const Icon(Icons.support_agent),
                        value: _assistencia24h,
                        onChanged: (value) {
                          setState(() {
                            _assistencia24h = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Valor estimado do seguro',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'R\$ ${valorSeguro.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('por ano'),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: novaCotacao,
                          child: const Text('Nova cotação'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(context);

                            enviarWhatsApp();
                          },
                          icon: const Icon(Icons.send),
                          label: const Text('Enviar'),
                        ),
                      ),
                    ],
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

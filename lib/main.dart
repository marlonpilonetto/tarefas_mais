import 'package:flutter/material.dart';
import 'db/db_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Inicialização obrigatória para desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const TarefasMaisApp());
}

class TarefasMaisApp extends StatelessWidget {
  const TarefasMaisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tarefas+',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
        fontFamily: 'Poppins',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
        fontFamily: 'Poppins',
      ),
      home: const TarefasDashboard(),
    );
  }
}

class TarefasDashboard extends StatefulWidget {
  const TarefasDashboard({super.key});

  @override
  State<TarefasDashboard> createState() => _TarefasDashboardState();
}

class _TarefasDashboardState extends State<TarefasDashboard> {
  List<Map<String, dynamic>> tarefas = [];

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  Future<void> _carregarTarefas() async {
    try {
      final lista = await DBHelper.listarTarefas();
      setState(() {
        tarefas = lista;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar tarefas: $e')),
      );
    }
  }

  void _abrirModalNovaTarefa() {
    String titulo = '';
    String subtitulo = '';
    Color corSelecionada = Colors.grey;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Nova Tarefa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => titulo = value,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Descrição / Prioridade',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => subtitulo = value,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Color>(
                value: corSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Nível de Prioridade',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: Colors.red, child: Text('Crítico')),
                  DropdownMenuItem(
                    value: Colors.orange,
                    child: Text('Alta prioridade'),
                  ),
                  DropdownMenuItem(
                    value: Colors.yellow,
                    child: Text('Média prioridade'),
                  ),
                  DropdownMenuItem(
                    value: Colors.green,
                    child: Text('Baixa prioridade'),
                  ),
                  DropdownMenuItem(
                    value: Colors.grey,
                    child: Text('Sem prioridade'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => corSelecionada = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save_alt),
              label: const Text('Salvar'),
              onPressed: () async {
                if (titulo.trim().isNotEmpty) {
                  await DBHelper.inserirTarefa({
                    'titulo': titulo,
                    'subtitulo': subtitulo,
                    'cor': corSelecionada,
                    'status': 'ativo',
                    'concluido': false,
                  });
                  Navigator.of(context).pop();
                  _carregarTarefas();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _alternarConclusao(int index) async {
    final tarefa = tarefas[index];
    final atualizado = {
      ...tarefa,
      'concluido': !(tarefa['concluido'] ?? false),
    };
    await DBHelper.atualizarTarefa(tarefa['id'], atualizado);
    _carregarTarefas();
  }

  void _excluirTarefa(int index) async {
    final tarefa = tarefas[index];
    await DBHelper.excluirTarefa(tarefa['id']);
    _carregarTarefas();
  }

  void _mostrarModalFiltrado(String tipo) {
    List<Map<String, dynamic>> filtradas;
    String titulo;

    if (tipo == 'concluido') {
      filtradas = tarefas.where((t) => t['concluido'] == true).toList();
      titulo = 'Tarefas Concluídas';
    } else if (tipo == 'pendente') {
      filtradas = tarefas
          .where((t) => (t['concluido'] ?? false) == false)
          .toList();
      titulo = 'Tarefas Pendentes';
    } else {
      filtradas = tarefas;
      titulo = 'Todas as Tarefas';
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(titulo),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filtradas.length,
            itemBuilder: (context, index) {
              final t = filtradas[index];
              final bool concluido = t['concluido'] ?? false;
              return Opacity(
                opacity: concluido ? 0.5 : 1.0,
                child: ListTile(
                  leading: Icon(
                    concluido
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: concluido ? Colors.green : Colors.grey,
                  ),
                  title: Text(t['titulo']),
                  subtitle: Text(t['subtitulo'] ?? ''),
                  trailing: Text(concluido ? '✅' : '⏳'),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tarefas+',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Tooltip(
            message: 'Todas',
            child: IconButton(
              icon: const Icon(Icons.list_alt_rounded),
              onPressed: () => _mostrarModalFiltrado('todos'),
            ),
          ),
          Tooltip(
            message: 'Concluídas',
            child: IconButton(
              icon: const Icon(Icons.check_circle_outline),
              onPressed: () => _mostrarModalFiltrado('concluido'),
            ),
          ),
          Tooltip(
            message: 'Pendentes',
            child: IconButton(
              icon: const Icon(Icons.pending_actions),
              onPressed: () => _mostrarModalFiltrado('pendente'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📅 Resumo Semanal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: tarefas.length,
                itemBuilder: (context, index) {
                  final tarefa = tarefas[index];
                  final bool concluido = tarefa['concluido'] ?? false;

                  return Opacity(
                    opacity: concluido ? 0.5 : 1.0,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Color(
                            tarefa['cor'] is int
                                ? tarefa['cor']
                                : Colors.grey.value,
                          ),
                          radius: 10,
                        ),
                        title: Text(
                          tarefa['titulo'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tarefa['subtitulo'] ?? ''),
                            const SizedBox(height: 4),
                            Text(
                              'Status: ${tarefa['status']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              tooltip: 'Marcar como concluída',
                              icon: Icon(
                                concluido
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: concluido ? Colors.green : Colors.grey,
                              ),
                              onPressed: () => _alternarConclusao(index),
                            ),
                            IconButton(
                              tooltip: 'Excluir tarefa',
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _excluirTarefa(index),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_tarefa',
        onPressed: _abrirModalNovaTarefa,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Nova Tarefa'),
      ),
    );
  }
}

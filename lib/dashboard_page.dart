import 'package:flutter/material.dart';
import 'db/db_helper.dart';

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
    final lista = await DBHelper.listarTarefas();
    setState(() {
      tarefas = lista;
    });
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
                  if (value != null) corSelecionada = value;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas+'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: _carregarTarefas,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: tarefas.isEmpty
            ? const Center(child: Text('Nenhuma tarefa cadastrada.'))
            : ListView.builder(
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
                          backgroundColor: tarefa['cor'] is Color
                              ? tarefa['cor']
                              : Colors.grey,
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_tarefa',
        onPressed: _abrirModalNovaTarefa,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Nova Tarefa'),
      ),
    );
  }
}
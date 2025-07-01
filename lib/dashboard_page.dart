import 'package:flutter/material.dart';
import 'db/api_service.dart';

class TarefasDashboard extends StatefulWidget {
  const TarefasDashboard({super.key});

  @override
  State<TarefasDashboard> createState() => _TarefasDashboardState();
}

class _TarefasDashboardState extends State<TarefasDashboard> {
  List<Map<String, dynamic>> tarefas = [];
  final TextEditingController _searchController = TextEditingController();
  String? _statusSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  Future<void> _carregarTarefas() async {
    final lista = await ApiService.buscarTarefas();
    final textoBusca = _searchController.text.toLowerCase();

    final filtrada = lista.where((tarefa) {
      final titulo = (tarefa['titulo'] ?? '').toLowerCase();
      final subtitulo = (tarefa['subtitulo'] ?? '').toLowerCase();
      final status = (tarefa['status'] ?? '').toLowerCase();

      final correspondeBusca =
          textoBusca.isEmpty ||
          titulo.contains(textoBusca) ||
          subtitulo.contains(textoBusca);

      final correspondeStatus =
          _statusSelecionado == null ||
          _statusSelecionado == 'todos' ||
          status == _statusSelecionado;

      return correspondeBusca && correspondeStatus;
    }).toList();

    setState(() {
      tarefas = filtrada;
    });
  }

  void _abrirModalNovaTarefa() {
    String titulo = '';
    String subtitulo = '';
    String corSelecionada = "#388E3C"; // verde padrão

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Adicionar Tarefa',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 18),
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
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => subtitulo = value,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: corSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Prioridade',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "#D32F2F", child: Text('Crítico', style: TextStyle(color: Color(0xFFD32F2F)))),
                    DropdownMenuItem(value: "#FFA000", child: Text('Alta', style: TextStyle(color: Color(0xFFFFA000)))),
                    DropdownMenuItem(value: "#FFEB3B", child: Text('Média', style: TextStyle(color: Color(0xFFFFEB3B)))),
                    DropdownMenuItem(value: "#388E3C", child: Text('Baixa', style: TextStyle(color: Color(0xFF388E3C)))),
                    DropdownMenuItem(value: "#9E9E9E", child: Text('Sem prioridade', style: TextStyle(color: Color(0xFF9E9E9E)))),
                  ],
                  onChanged: (value) {
                    if (value != null) corSelecionada = value;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text('Cancelar'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt),
                      label: const Text('Salvar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (titulo.trim().isNotEmpty) {
                          await ApiService.criarTarefa({
                            'titulo': titulo,
                            'subtitulo': subtitulo,
                            'cor': corSelecionada,
                            'status': 'ativo',
                            'concluido': false,
                          });
                          Navigator.of(context).pop();
                          await _carregarTarefas();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
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
    await ApiService.atualizarTarefa(tarefa['id'], atualizado);
    _carregarTarefas();
  }

  void _excluirTarefa(int index) async {
    final tarefa = tarefas[index];
    try {
      await ApiService.excluirTarefa(tarefa['id']);
      _carregarTarefas();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir tarefa: $e')),
      );
    }
  }

  Color _parseColor(dynamic cor) {
    if (cor is String && cor.startsWith('#')) {
      String hex = cor.substring(1);
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF1565C0)),
            const SizedBox(width: 8),
            const Text(
              'Tarefas+',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.black, // <-- preto
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1565C0)),
            tooltip: 'Atualizar',
            onPressed: _carregarTarefas,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                // Barra de busca e filtro
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => _carregarTarefas(),
                        decoration: InputDecoration(
                          labelText: 'Buscar tarefa',
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: const Icon(Icons.search, color: Colors.black),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _statusSelecionado,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'todos',
                            child: Text('Todos', style: TextStyle(color: Colors.black)),
                          ),
                          DropdownMenuItem(
                            value: 'ativo',
                            child: Text('Ativo', style: TextStyle(color: Colors.black)),
                          ),
                          DropdownMenuItem(
                            value: 'inativo',
                            child: Text('Inativo', style: TextStyle(color: Colors.black)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _statusSelecionado = value;
                          });
                          _carregarTarefas();
                        },
                        style: const TextStyle(color: Colors.black),
                        iconEnabledColor: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Lista de tarefas
                Expanded(
                  child: tarefas.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhuma tarefa encontrada.',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: tarefas.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final tarefa = tarefas[index];
                            final bool concluido = tarefa['concluido'] ?? false;

                            return Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              color: Colors.white,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: _parseColor(tarefa['cor']),
                                  radius: 16,
                                  child: Icon(
                                    concluido ? Icons.check : Icons.assignment_turned_in,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  tarefa['titulo'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Colors.black, // <-- preto
                                    decoration: concluido
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tarefa['subtitulo'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.black, // <-- preto
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Status: ${tarefa['status']}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.black, // <-- preto
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Wrap(
                                  spacing: 4,
                                  children: [
                                    IconButton(
                                      tooltip: concluido
                                          ? 'Desmarcar conclusão'
                                          : 'Marcar como concluída',
                                      icon: Icon(
                                        concluido
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: concluido
                                            ? Colors.green
                                            : Colors.blue[800],
                                        size: 22,
                                      ),
                                      onPressed: () => _alternarConclusao(index),
                                    ),
                                    IconButton(
                                      tooltip: 'Excluir tarefa',
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 22,
                                      ),
                                      onPressed: () => _excluirTarefa(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_tarefa',
        backgroundColor: const Color(0xFF1565C0),
        onPressed: _abrirModalNovaTarefa,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nova Tarefa',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}


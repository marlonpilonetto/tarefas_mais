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

  // Controle do modo escuro
  bool _darkMode = false;

  // Cores claras
  static const corFundo = Color(0xFF2563EB);
  static const corContainer = Color(0xFFF3F4F6);
  static const corTexto = Color(0xFF1F2937);

  // Cores escuras
  static const corFundoDark = Color(0xFF181C2A);
  static const corContainerDark = Color(0xFF23263A);
  static const corTextoDark = Color(0xFFF3F4F6);

  Color get _bgColor => _darkMode ? corFundoDark : corFundo;
  Color get _containerColor => _darkMode ? corContainerDark : corContainer;
  Color get _textColor => _darkMode ? corTextoDark : corTexto;
  Color get _inputFillColor => _darkMode ? const Color(0xFF23263A) : Colors.white;
  Color get _inputBorderColor => _darkMode ? corTextoDark : Colors.black;

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
          child: Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _containerColor,
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
                  Text(
                    'Nova Tarefa',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: _textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Título',
                      labelStyle: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: _inputBorderColor, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: _inputBorderColor, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: _inputBorderColor, width: 2),
                      ),
                      filled: true,
                      fillColor: _inputFillColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                    style: TextStyle(color: _textColor),
                    onChanged: (value) => titulo = value,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      labelStyle: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: _inputBorderColor, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: _inputBorderColor, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: _inputBorderColor, width: 2),
                      ),
                      filled: true,
                      fillColor: _inputFillColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                    style: TextStyle(color: _textColor),
                    onChanged: (value) => subtitulo = value,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: corSelecionada,
                    decoration: InputDecoration(
                      labelText: 'Prioridade',
                      labelStyle: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: _inputBorderColor, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: _inputBorderColor, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: _inputBorderColor, width: 2),
                      ),
                      filled: true,
                      fillColor: _inputFillColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
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
                    style: TextStyle(color: _textColor),
                    iconEnabledColor: _textColor,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text('Cancelar', style: TextStyle(color: _textColor)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save_alt, color: Colors.white),
                        label: const Text('Salvar', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
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
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black12, width: 1.5),
              color: _containerColor,
            ),
            margin: const EdgeInsets.all(12),
            child: Column(
              children: [
                // AppBar customizada
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Image.asset(
                        _darkMode ? 'lib/imagens/logo_dark.png' : 'lib/imagens/logo.png',
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: _darkMode ? Colors.white : corTexto,
                          size: 26,
                        ),
                        tooltip: 'Atualizar',
                        onPressed: _carregarTarefas,
                      ),
                      // Botão de dark mode
                      IconButton(
                        icon: Icon(
                          _darkMode ? Icons.dark_mode : Icons.light_mode,
                          color: _darkMode ? corTextoDark : corTexto,
                          size: 26,
                        ),
                        tooltip: _darkMode ? 'Modo claro' : 'Modo escuro',
                        onPressed: () {
                          setState(() {
                            _darkMode = !_darkMode;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                // Busca
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => _carregarTarefas(),
                    decoration: InputDecoration(
                      labelText: 'Buscar tarefa',
                      labelStyle: TextStyle(color: _textColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      prefixIcon: Icon(Icons.search, color: _textColor),
                      filled: true,
                      fillColor: _inputFillColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                    style: TextStyle(color: _textColor),
                  ),
                ),
                // Filtro de status
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: DropdownButtonFormField<String>(
                    value: _statusSelecionado,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: TextStyle(
                        color: _textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      filled: true,
                      fillColor: _inputFillColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'todos',
                        child: Text('-', style: TextStyle(color: corTexto)),
                      ),
                      DropdownMenuItem(
                        value: 'ativo',
                        child: Text('Ativo', style: TextStyle(color: corTexto)),
                      ),
                      DropdownMenuItem(
                        value: 'inativo',
                        child: Text('Inativo', style: TextStyle(color: corTexto)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _statusSelecionado = value;
                      });
                      _carregarTarefas();
                    },
                    style: TextStyle(color: _textColor),
                    iconEnabledColor: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                // Lista de tarefas
                Expanded(
                  child: tarefas.isEmpty
                      ? Center(
                          child: Text(
                            'Nenhuma tarefa encontrada.',
                            style: TextStyle(
                              color: _textColor,
                              fontSize: 18,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          itemCount: tarefas.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final tarefa = tarefas[index];
                            final bool concluido = tarefa['concluido'] ?? false;

                            return Container(
                              decoration: BoxDecoration(
                                color: _inputFillColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black12, width: 1),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: _parseColor(tarefa['cor']),
                                  radius: 18,
                                  child: Icon(
                                    concluido ? Icons.check : Icons.circle_outlined,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                title: Text(
                                  tarefa['titulo'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: _textColor,
                                  ),
                                ),
                                subtitle: Text(
                                  'Status: ${tarefa['status']}',
                                  style: TextStyle(
                                    color: _textColor,
                                    fontSize: 13,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.radio_button_unchecked, color: _textColor, size: 28),
                                      onPressed: () => _alternarConclusao(index),
                                      tooltip: concluido
                                          ? 'Desmarcar conclusão'
                                          : 'Marcar como concluída',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 26),
                                      tooltip: 'Excluir tarefa',
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            backgroundColor: _containerColor,
                                            title: Text('Excluir tarefa', style: TextStyle(color: _textColor)),
                                            content: Text('Tem certeza que deseja excluir esta tarefa?', style: TextStyle(color: _textColor)),
                                            actions: [
                                              TextButton(
                                                child: Text('Cancelar', style: TextStyle(color: _textColor)),
                                                onPressed: () => Navigator.of(context).pop(false),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: const Text('Excluir'),
                                                onPressed: () => Navigator.of(context).pop(true),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          _excluirTarefa(index);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: Center(
                                          child: Container(
                                            constraints: const BoxConstraints(maxWidth: 400),
                                            padding: const EdgeInsets.all(24),
                                            decoration: BoxDecoration(
                                              color: _containerColor,
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
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                Text(
                                                  'Detalhes da Tarefa',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 22,
                                                    color: _textColor,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 18),
                                                Text(
                                                  'Título',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: _textColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  tarefa['titulo'] ?? '',
                                                  style: TextStyle(
                                                    color: _textColor,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'Descrição',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: _textColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  tarefa['subtitulo'] ?? '',
                                                  style: TextStyle(
                                                    color: _textColor,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'Prioridade',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: _textColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor: _parseColor(tarefa['cor']),
                                                      radius: 10,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      _prioridadeTexto(tarefa['cor']?.toString()),
                                                      style: TextStyle(
                                                        color: _parseColor(tarefa['cor']),
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 24),
                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child: TextButton(
                                                    child: Text('Fechar', style: TextStyle(color: _textColor)),
                                                    onPressed: () => Navigator.of(context).pop(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
                // Botão Nova Tarefa
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Nova Tarefa',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      onPressed: _abrirModalNovaTarefa,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _prioridadeTexto(dynamic cor) {
    final corStr = cor?.toString();
    switch (corStr) {
      case "#D32F2F":
        return "Crítico";
      case "#FFA000":
        return "Alta";
      case "#FFEB3B":
        return "Média";
      case "#388E3C":
        return "Baixa";
      case "#9E9E9E":
        return "Sem prioridade";
      default:
        return "Desconhecida";
    }
  }
}


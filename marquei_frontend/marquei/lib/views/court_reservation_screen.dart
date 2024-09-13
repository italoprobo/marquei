import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class CourtReservationScreen extends StatefulWidget {
  final int courtId;
  final String courtName;

  const CourtReservationScreen({
    super.key,
    required this.courtId,
    required this.courtName,
  });

  @override
  _CourtReservationScreenState createState() => _CourtReservationScreenState();
}

class _CourtReservationScreenState extends State<CourtReservationScreen> {
  List<DateTime> availableTimes = [];
  List<DateTime> selectedTimes = [];
  bool isLoading = true;
  Map<DateTime, bool> reservedTimes = {};
  DateTime selectedDate = DateTime.now(); // Data selecionada

  @override
  void initState() {
    super.initState();
    _generateAvailableTimes();
    _fetchReservedTimes();
  }

  // Gera os horários disponíveis de 16:00 até 00:00
  void _generateAvailableTimes() {
    DateTime start = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 16, 0);
    DateTime end =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0)
            .add(Duration(days: 1));

    availableTimes.clear();
    for (DateTime time = start;
        time.isBefore(end);
        time = time.add(Duration(hours: 1))) {
      availableTimes.add(time);
    }
    setState(() {});
  }

  // Busca os horários reservados no Supabase com base na data selecionada
  Future<void> _fetchReservedTimes() async {
    setState(() {
      isLoading = true;
      reservedTimes.clear();
    });

    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('reserva')
        .select('data, hora_inicio, hora_fim')
        .eq('id_quadra', widget.courtId)
        .eq(
            'data',
            selectedDate
                .toIso8601String()
                .substring(0, 10)); // Usa a data selecionada

    if (response != null && response is List) {
      for (var reservation in response) {
        DateTime horaInicio = DateTime.parse(
            '${reservation['data']} ${reservation['hora_inicio']}');
        reservedTimes[horaInicio] = true;
      }
    } else {
      print('Nenhuma reserva encontrada para esta quadra.');
    }

    setState(() {
      isLoading = false;
    });
  }

  // Função para confirmar a reserva de múltiplos horários
  Future<void> _confirmReservation() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        final response = await supabase
            .from('usuarios')
            .select('id')
            .eq('id_auth', user.id)
            .maybeSingle();

        if (response == null || response['id'] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Erro: usuário não encontrado na tabela usuários.')),
          );
          return;
        }

        final userId = response['id'];

        for (var time in selectedTimes) {
          final response = await supabase.from('reserva').insert({
            'id_user_auth': user.id,
            'id_quadra': widget.courtId,
            'data': selectedDate
                .toIso8601String()
                .substring(0, 10), // Usa a data selecionada
            'hora_inicio': time.toIso8601String().substring(11, 19),
            'hora_fim': time
                .add(Duration(hours: 1))
                .toIso8601String()
                .substring(11, 19),
            'preco': 50.00,
          });

          if (response == null) {
            reservedTimes[time] = true;
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Reserva confirmada para ${selectedTimes.length} horário(s)')),
        );
        setState(() {
          selectedTimes.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao confirmar reserva: $e')),
        );
      }
    }
  }

  // Função para alternar a seleção de horários
  void _toggleTimeSelection(DateTime time) {
    setState(() {
      if (selectedTimes.contains(time)) {
        selectedTimes.remove(time);
      } else {
        selectedTimes.add(time);
      }
    });
  }

  // Função para selecionar a data
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _generateAvailableTimes();
        _fetchReservedTimes();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservar ${widget.courtName}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exibe a data selecionada acima do botão
                      Text(
                        'Data selecionada: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                          height: 8), // Espaçamento entre o texto e o botão
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          textStyle: TextStyle(fontSize: 16),
                        ),
                        onPressed: _selectDate, // Abre o seletor de data
                        child: const Text('Selecionar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Selecione um ou mais horários para ${widget.courtName}:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: availableTimes.length,
                      itemBuilder: (context, index) {
                        DateTime time = availableTimes[index];
                        bool isReserved = reservedTimes[time] ?? false;
                        bool isSelected = selectedTimes.contains(time);
                        return GestureDetector(
                          onTap: isReserved
                              ? null
                              : () {
                                  _toggleTimeSelection(time);
                                },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isReserved
                                  ? Colors.grey
                                  : isSelected
                                      ? Colors.blue
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isReserved ? Colors.grey : Colors.blue,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              '${time.hour}:00 - ${time.hour + 1}:00',
                              style: TextStyle(
                                color: isReserved
                                    ? Colors.white
                                    : isSelected
                                        ? Colors.white
                                        : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        selectedTimes.isEmpty ? null : _confirmReservation,
                    child: Text(
                        'Confirmar Reserva (${selectedTimes.length} horário(s))'),
                  ),
                ],
              ),
            ),
    );
  }
}

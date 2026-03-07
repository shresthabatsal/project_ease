import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/features/support/domain/entities/ticket_entity.dart';
import 'package:project_ease/features/support/domain/usecases/create_ticket_usecase.dart';
import 'package:project_ease/features/support/domain/usecases/get_user_tickets_usecase.dart';
import 'package:project_ease/features/support/presentation/state/support_state.dart';

final ticketListViewModelProvider =
    NotifierProvider<TicketListViewModel, TicketListState>(
      () => TicketListViewModel(),
    );

class TicketListViewModel extends Notifier<TicketListState> {
  late final GetUserTicketsUsecase _getUserTickets;
  late final CreateTicketUsecase _createTicket;

  @override
  TicketListState build() {
    _getUserTickets = ref.read(getUserTicketsUsecaseProvider);
    _createTicket = ref.read(createTicketUsecaseProvider);
    Future.microtask(loadTickets);
    return const TicketListState();
  }

  Future<void> loadTickets() async {
    state = state.copyWith(status: SupportStatus.loading);
    final result = await _getUserTickets();
    result.fold(
      (f) => state = state.copyWith(
        status: SupportStatus.error,
        errorMessage: f.message,
      ),
      (tickets) => state = state.copyWith(
        status: SupportStatus.success,
        tickets: tickets,
      ),
    );
  }

  Future<TicketEntity?> createTicket({
    required String title,
    required String description,
    required String category,
    required String priority,
  }) async {
    state = state.copyWith(status: SupportStatus.submitting);
    final result = await _createTicket(
      CreateTicketParams(
        title: title,
        description: description,
        category: category,
        priority: priority,
      ),
    );
    return result.fold(
      (f) {
        state = state.copyWith(
          status: SupportStatus.error,
          errorMessage: f.message,
        );
        return null;
      },
      (ticket) {
        state = state.copyWith(
          status: SupportStatus.success,
          tickets: [ticket, ...state.tickets],
        );
        return ticket;
      },
    );
  }

  void updateTicketInList(TicketEntity updated) {
    final list = state.tickets
        .map((t) => t.ticketId == updated.ticketId ? updated : t)
        .toList();
    state = state.copyWith(tickets: list);
  }
}

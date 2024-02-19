import 'package:hasior_flutter/models/ticketRequest.dart';

class TicketRequestWithSelect {
  TicketRequestWithSelect({
    required this.ticketRequest,
    required this.isSelected,
  });

  TicketRequest ticketRequest;
  bool isSelected;
}

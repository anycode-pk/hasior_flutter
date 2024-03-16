class AcceptingRequests extends StatefulWidget {
  final int id;
  const AcceptingRequests({super.key, required this.id});

  @override
  State<AcceptingRequests> createState() => _AcceptingRequestsState();
}

class _AcceptingRequestsState extends State<AcceptingRequests> {
  static const grayColor = Color.fromRGBO(105, 105, 105, 1);
  List<TicketRequestWithSelect> ticketRequestsWithSelect = [];
  List<TicketRequest> selectedTicketRequests = [];
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _getData();
  }
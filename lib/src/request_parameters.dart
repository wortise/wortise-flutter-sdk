enum CollapsiblePosition {
  bottom,
  top,
}

class RequestParameters {

  final String? agent;

  final CollapsiblePosition? collapsible;

  const RequestParameters({
    this.agent,
    this.collapsible,
  });


  Map<String, dynamic> get toMap => {
    "agent": agent,
    "collapsible": collapsible?.name,
  };
}

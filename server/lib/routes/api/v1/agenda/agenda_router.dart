import 'package:server/routes/api/v1/agenda/cycles/cycles_route_handler.dart';
import 'package:server/routes/api/v1/agenda/reference-date/reference_date_route_handler.dart';
import 'package:shelf_router/shelf_router.dart';

Router createAgendaRouter() {
  final router =
      Router()
        ..all('/cycles', cyclesRouteHandler)
        ..all('/reference-date', referenceDateRouteHandler);

  return router;
}

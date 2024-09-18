String base = 'http://192.168.155.221:6042';
// String base = 'http://128.199.199.164:6042';
String version = "v1";
String loginPath = '/api/$version/user_login';
String registationPath = '/api/$version/user_registration';
String startWorkPath = '/api/$version/attendance/start_work';
String dashBoardGetDataPath = '/api/$version/reports/dashboard';
String endWorkPath = '/api/$version/attendance/end_work';
String getDelivaryList = '/api/$version/delivery/v2/list';
String saveDeliveryList = '/api/$version/delivery/save';
String cashCollectionList = '/api/$version/cash_collection/v2/list';
String cashCollectionSave = '/api/$version/cash_collection/save';
String getCoustomerList = '/api/$version/customer_location/list';
String getCoustomerDetailsByPartnerID =
    '/api/$version/customer_location/details';
String setCoustomerLatLon =
    "/api/$version/customer_location/customer_location_update";
String conveyanceStart = "/api/$version/conveyance/start";
String conveyanceList = "/api/$version/conveyance/list";
String conveyanceEnd = "/api/$version/conveyance/end";
String conveyanceTransportMode = "/api/$version/conveyance/transport_modes";

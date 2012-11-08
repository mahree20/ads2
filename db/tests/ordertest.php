<?php
require '../order.php';


$data = json_decode('{"id":"11","date":"1352334438.11","downpayment":null,"date_paid":null,"date_claimed":1352334820332,"due":null,"items":[{"id":"23","order_id":"11","price":"300.0","quantity":"1","product":{"id":"4","name":"Graphic M"},"subtotal":300},{"id":"24","order_id":"11","price":"97.5","quantity":"1","product":{"id":"2","name":"Avon Naturals Hair Care"},"subtotal":97.5}],"user":{"id":"1","fullname":"Saligan, Wendell Philip B."},"total":397.5}');
$data->user_id = 1;
$order = Order::findById(11);
#$order->save();
$order->update($data);
print_r($order->as_array());
#print_r($data);


?>

<?php 
require_once "../db/general.php";

class OrderCtrl{

	public static function get(){
		return function($request,$response){
			$user_id = $request->session('id');

			if ($user_id){
				$id = $request->id;
				$order = Order::findById($id);
				if($order){
					$response->json($order->as_array());	
				}else{
					$response->code(404);
				}
				
			}else{
				$response->code(403);
			}
		};
		
	}

	public static function change(){
		return function($request, $response){
			$user_id = $request->session('id');

			if($user_id){
				$id = $request->id;
				$order = Order::findById($id);

				if($order){
					$data = $request->data();
					$data->user_id = $user_id;
					$order->update($data);
					$response->json($order->as_array());

				}else{
					$response->code(404);
				}
			}else{
				$response->code(403);
			}
		};
	}

	public static function create(){

		return function($request,$response){
			$user_id = $request->session('id');
			if($user_id){
				$data = $request->data();
				$data->user_id = $user_id;
				try{
					$order = Order::create($data);
					#$order->save();
					$response->json($order->as_array());
					#echo "create";	
				}catch(Exception $e){
					echo $e->getMessage();
				}
				
				
			}else{
				$response->code(403);
			}

		};
	}

	public static function admin_index(){
		return function($request, $response){
			$user_id = $request->user;
			$orders = Order::findByUser($user_id);
			#$order_arr = array();
			#foreach ($orders as $order) {
			#	# code...
			#	$order_arr[] = $order->as_array();
			#}
			if($orders){
				$response->json($orders->as_array());	
			} else {
				$response->code(404);
			}

			
		};
	}

	public static function user_index(){
		return function($request,$response){
			$user_id = $request->session('id');
			
			
			$orders = Order::findByUser($user_id);
			if(!$user_id){
				$response->code(403);

			}else {
				if($orders){
					$response->json($orders->as_array());
				}else{
					$response->json(array());
				}
			}
			
		};
	}
}

 ?>
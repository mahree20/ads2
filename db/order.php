<?php
require_once "general.php";

class Order extends Model{
	public static $_table = 'orders';
	protected static $class =  'Order';

//Getters
	public function getId(){
		return $this->_orm->id;
	}

	public function getUser(){
		$user = User::findById($this->_orm->user_id);
		return $user;
	}

	public function getDownpayment(){
		return $this->_orm->downpayment;
	}

	public function getBalance(){
		$balance = $this->total - $this->downpayment;
		return $balance;
	}

	public function getItems(){
		$items = OrderItem::findByOrder($this->id);
		if($items){
			return $items;
		}
		return null;
	}

	public function getDate(){
		return $this->_orm->date;
	}

	public function getDate_paid(){
		return $this->_orm->date_paid;
	}

	public function getDate_claimed(){
		return $this->_orm->date_claimed;
	}

	public function getDue(){
		return $this->_orm->due;
	}

	public function getTotal(){
		$items = $this->items ? $this->items : array();
		$total = 0;
		foreach ($items as $item) {
			# code...
			$total += $item->subtotal;
		}
		return $total;
	}

	//************************//
	//**** SETTERS  **********//
	//************************//

	public function setUser_id($value){
		$this->_orm->user_id = $value;
	}

	public function setDate($value){
		$this->_orm->date = $value;

	}
	public function setDownpayment($value){
		$this->_orm->downpayment = $value;
	}

	public function setDate_paid($value){
		$this->_orm->date_paid = $value;
	}

	public function setDate_claimed($value){
		$this->_orm->date_claimed = $value;
	}

	public function setDue($value){
		$this->_orm->due = $value;
	}

	public function as_array(){
		$model = $this->_orm->as_array();
		unset($model['user_id']);
		$model['items'] = $this->items ? $this->items->as_array() : null;
		$model['user'] = array(
				'id' => $this->user->id,
				'fullname' => $this->user->profile->fullname
			);
		$model['total'] = $this->total;

		return $model;
	}

	public function delete(){
		$items = $this->items;
		$this->_orm->delete();
		$items->delete();
		return true;
	}

//Setters
	public function setUser($value){
		if($value instanceof User){
			$this->_orm->user_id = $value->id;
			return true;
		}
		$user = User::findById($value);
		if($user){
			$this->_orm->user_id = $user->id;
			return true;
		}else{
			throw new Exception("User does not exist");
			
		}
	}

	
	public function addItem($item=null){
		if($item instanceof OrderItem){
			$item->order = $this->id;
			$item->save();
			return true;
		}
		$item = new OrderItem();
		$item->order = $this->id;
		return $item;
	}

	public function update($data){
		$this->user_id 	= 	$data->user_id ? $data->user_id : $this->user_id;
		$this->date 	= 	$data->date ? $data->date : $this->date;
		$this->downpayment 	= 	$data->downpayment ? $data->downpayment : $this->downpayment;
		$this->date_paid 	=	$data->date_paid ? $data->date_paid : $this->date_paid;
		$this->date_claimed =	$data->date_claimed ? $data->date_claimed : $this->date_claimed;
		$this->due 		=	$data->due ? $data->due : $this->due;

		$this->save(); 
	}

	public static function create($data){
		$order = new Order();
		if($data){
			$order->user_id 	= 	$data->user_id ? $data->user_id : $order->user_id;
			$order->date 	= 	$data->date ? $data->date : $order->date;
			$order->downpayment 	= 	$data->downpayment ? $data->downpayment : $order->downpayment;
			$order->date_paid 	=	$data->date_paid ? $data->date_paid : $order->date_paid;
			$order->date_claimed =	$data->date_claimed ? $data->date_claimed : $order->date_claimed;
			$order->due 		=	$data->due ? $data->due : $order->due;
			
			$order->save();
			
			if($data->items){
				foreach ($data->items as $itemdata) {
					$item = $order->addItem();
					$item->product = $itemdata->id;
					$item->price = $itemdata->price;
					$item->quantity = $itemdata->quantity;
					$item->save();
				}
			}

			return $order;
		}
		throw new Exception("$data must not be empty", 1);
		
	}

	public static function findByUser($user_id){
		$orders = ORM::for_table(static::$_table)->where('user_id', $user_id)->find_many();
		
		if($orders){
			$models = array();
			foreach ($orders as $order) {
				# code...
				$models[] = new Order($order);
			}
			return new Collection($models);
		}
		return null;
	}

}

?>

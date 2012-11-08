UserCatalogCtrl = ['$scope','Company','Category','Product','Cart','$location', 
($scope,Company, Category,Product,Cart,$location)->
	$scope.companies = Company.query()
	$scope.categories = Category.query()
	$scope.products = Product.query()

	console.log $scope.categories
	console.log $scope.companies
	console.log $scope.products

	$scope.add = (product)->
		product.quantity = 1
		Cart.add(product)
		$location.path('/cart')

]

UserIndexCtrl = ['$scope','$http', ($scope,$http)->
	#humane.log('welcome')
	
]

UserCartCtrl = ['$scope','Cart','$location','Order', ($scope,Cart,$location,Order)->
	
	$scope.items = Cart.items
	#window.cartitems = $scope.items
	window.cart = Cart
	$scope.total = ->
		st = (item.price*item.quantity for item in $scope.items)
		#console.log st
		t=0
		(t+=subtotal for subtotal in st)
		#console.log t
		Cart.store($scope.items)
		return t
	$scope.remove = (item)->
		Cart.removeItem(item)
	$scope.clear = ->
		$scope.items = []
		Cart.clear()
		
		humane.log("Cart cleared.")
	$scope.order = ->
		order = new Order()
		order.date = Date.now() / 1000
		order.items = $scope.items
		order.$save()
		$scope.clear()
		$location.path('/orders')
	$scope.$on('logout',(event)->
		$scope.clear()
	)
]

UserOrderCtrl = ['$scope','Order',($scope,Order)->
	window.order = Order
	Order.query((data)->
		$scope.orders = data
		console.log $scope.orders
	)
]

UserProfileCtrl = ['$scope','$http',($scope,$http)->
	$http.get('/profile').success (data)->
		$scope.profile = data
	
	$scope.submit = ->
		$http.post('/profile', JSON.stringify($scope.profile)).success (data)->
			$scope.profile = data
			$scope.saved=true
			humane.log('Profile Saved')
			console.log(data)
		
]

MenuCtrl = ['$scope','Cart','$location','$rootScope','Order', ($scope,Cart,$location,$rootScope,Order)->
	Order.query((data)->
		$scope.order = data.length
		)
	
	$scope.count = ->
		Cart.items.length

	$scope.logout = ->
		#$location.path('/')
		$rootScope.$broadcast('logout',{})
		$location.path('/logout')
		Cart.clear()
]

ChangePassCtrl = ['$scope','$http',($scope,$http)->
	$ = $scope
	$.verified = false	

	$scope.verify = ->
		$http.post('/verify_password',JSON.stringify($scope.user)).success(->
			console.log JSON.stringify $.user
			$.verified = true
			#humane.log('password correct!')
		)
		.error(->
			$.fail = true
			console.log JSON.stringify $.user
			$.user.password = ""
			humane.log('wrong password!')
		)
	$.change = ->
		$.status = ""
		p1 = $.new.password
		p2 = $.new.password_conf
		pack = 
			password: $.user.password
			new_password: p1
			new_password_confirm: p2
		pack = JSON.stringify pack
		if(p1 == p2)
			$http.post('/change_password', pack).success(->
				humane.log('Password Changed Successfully')
				$.new = {}
				$.verified = false
				$.user = {}
			).error(->
				humane.log("Password error")
			)
		else
			$.status = "error"
			humane.log('Passwords do not match')
			$.new = {}
		console.log pack
]

RegisterCtrl = ['$scope','$http',($scope,$http)->
	$scope.login = false
	$scope.check_username = ()->

		$uname = $scope.user.username
		console.log $uname
		if($uname == undefined)
			$scope.username_invalid = false
			$scope.username_valid = false
			$scope.username_state = "error"
		else
			$http.get("/check/#{$uname}").error(->
				$scope.valid=true
				$scope.username_state = "success"
				$scope.username_valid = true
				$scope.username_invalid = false
				console.log "valid username"
				)
			.success(->
				$scope.valid = false
				$scope.username_state = "error"
				$scope.username_invalid = true
				$scope.username_valid = false
				console.log "username already taken"
				)
	$scope.confirm = ->
		if($scope.user.password != undefined)
			if($scope.user.password == $scope.user.password_confirm)
				$scope.password_state = "success"
				$scope.password_valid = true
				console.log "equal"
			else
				$scope.password_state = "error"
				$scope.password_valid = false
				console.log "not equal"
		else
			$scope.password_state = "error"
			$scope.password_valid = false
	$scope.submit = ->
		$scope.profile.birthday = "#{$scope.profile.bday.month}/#{$scope.profile.bday.day}/#{$scope.profile.bday.year}"
		pack = 
			user:$scope.user
			profile:$scope.profile
		pack = JSON.stringify(pack)
		$http.post('/user', pack).success((data)-> 
			$scope.user = {}
			$scope.profile = {}
			$scope.login = true
		).error(->
			$scope.failed = true
		)

		console.log pack
]

ads.controller('RegisterCtrl', RegisterCtrl)
ads.controller('MenuCtrl', MenuCtrl)
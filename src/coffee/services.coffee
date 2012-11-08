rest = angular.module('restService', ['ngResource'])
rest.factory('Product', ['$resource',($resource)->
	$resource('/product/:id.json',{id:'@id'},{
		query: {method:'GET',params:{id:'all'}, isArray:true}
	})
	]
)

rest.factory('Brand',['$resource',($resource)->
	$resource('/brand/:id.json/:products',{id:'@id'},{
		query: {method:'GET', params:{id:'all'}, isArray: true},
		products: {method: 'GET', params:{products: 'products'}, isArray: true}
		})
	]
)

rest.factory('Company',['$resource',($resource)->
	$resource('/company/:id.json/:products',{id: '@id'},{
		query: {method:'GET', params: {id: 'all'}, isArray: true}
		products: {method: 'GET', params: {products: 'products'}, isArray: true}
		})
	])

rest.factory('Category',['$resource',($resource)->
	$resource('/category/:id.json/:products',{id:'@id'},{
		query: {method:'GET', params:{ id:'all'}, isArray: true}
		products: {method:'GET', params: {products: 'products'}, isArray: true}
		})
	])

rest.factory('Order',['$resource',($resource)->
	$resource('/orders/:id', {id:'@id'})
])

rest.service('localStorageService',[->
	return {
		prefix: 'ads.'
		isSupported: ->
			try
				'localStorage' of window and window['localStorage']?
			catch e
				false

		add: (key,value)->
			try
				localStorage.setItem(@prefix+key, value)
			catch e
				console.error(e.Description)
				-1
		get: (key)->
			
			localStorage.getItem(@prefix+key)

		remove: (key)->
			localStorage.removeItem(@prefix+key)

		clearAll: ->
			prefixLength = @prefix.length
			keys = (i for i of localStorage when i.substr(0,prefixLength) == @prefix)
			#console.log keys

			for q in keys
				do (q) ->
					#console.log q
					localStorage.removeItem(q)
	}

])

rest.factory('Cart',['localStorageService',(localStorageService)->
	getCartItems = ->
		if localStorageService.get('cart')?
			strCart = localStorageService.get('cart')
			return JSON.parse strCart
		else
			localStorageService.add('cart','[]')
			strCart = localStorageService.get('cart')
			return JSON.parse strCart
	cart = {
		persist: ->
			localStorageService.add('cart',JSON.stringify(@items))
		items: getCartItems()
		add: (obj)->
			key = @items.push(obj)
			str = JSON.stringify(@items)
			localStorageService.add('cart',str)
			console.log localStorageService.get('cart')
			key
		get: (key)->
			@items[key]
		getItem: (obj) ->
			key = @items.indexOf(obj)
			if (key >= 0)
				return key
			else
				return false

		set: (key,value)->
			@items[key] = value
			@persist()
			value
		store: (obj) ->
			@items = obj
			@persist()
		remove: (key)->
			@items.splice(key,1)
			@persist()
		removeItem: (obj)->
			key = @items.indexOf(obj)
			@remove(key)
		removeById: (id)->
			obj = (i for i in @items when i.id == id)
			console.log obj
			obj
		clear: ->
			@items = []
			@persist()
	}


])
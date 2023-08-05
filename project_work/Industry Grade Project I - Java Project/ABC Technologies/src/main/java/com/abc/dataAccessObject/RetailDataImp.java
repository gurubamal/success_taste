package com.abc.dataAccessObject;

import java.util.HashMap;
import java.util.Map;
import com.abc.RetailModule;
import com.abc.dataAccessObject.RetailAccessObject;


public class RetailDataImp implements RetailAccessObject {

	Map<Integer,RetailModule> users = new HashMap<>();
	
	
	@Override
	public void create(RetailModule product) {
		users.put(product.getProduct_id(),product);
	}

	@Override
	public RetailModule read(int product_id) {
		return users.get(product_id);
	}
	

}

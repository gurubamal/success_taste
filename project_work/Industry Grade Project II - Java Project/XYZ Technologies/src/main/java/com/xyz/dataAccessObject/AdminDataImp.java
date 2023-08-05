package com.xyz.dataAccessObject;

import java.util.HashMap;
import java.util.Map;
import com.xyz.AdminModule;


public class AdminDataImp implements AdminDataAccessObject {

	Map<Integer,AdminModule> users = new HashMap<>();
	
	
	@Override
	public void create(AdminModule user) {
		users.put(user.getUser_id(),user);
	}

	@Override
	public AdminModule read(int user_id) {
		return users.get(user_id);
	}

	@Override
	public void delete(AdminModule user) {
		users.remove(user.getUser_id(),user);
		
	}

	

}

package com.xyz.dataAccessObject;

import static org.junit.Assert.*;

import org.junit.Test;

import com.xyz.AdminModule;

public class AdminDataImpTest {

	@Test
	public void createUserShouldWorkSuccessfully() {
		AdminDataAccessObject obj = new AdminDataImp();
		AdminModule user = new AdminModule();
		
		user.setUser_id(2001);
		user.setUser_name("DemoName");
		user.setUser_emailId("demo.name@xyz.com");
		user.setAge(28);
		obj.create(user);
	
		AdminModule result = obj.read(2001);
		assertNotNull(result);
		assertEquals("DemoName", result.getUser_name());
	}

}

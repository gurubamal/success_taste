package com.abc.dataAccessObject;

import static org.junit.Assert.*;

import org.junit.Test;

import com.abc.RetailModule;

public class ProductImpTest {

	@Test
	public void createUserShouldWorkSuccessfully() {
		RetailAccessObject obj = new RetailDataImp();
		RetailModule product = new RetailModule();
		
		product.setProduct_id(2001);
		product.setProduct_name("DemoName");
		product.setProduct_description("demo description");
		product.setPrice(280);
		obj.create(product);
	
		RetailModule result = obj.read(2001);
		assertNotNull(result);
		assertEquals("DemoName", result.getProduct_name());
	}
	@Test
	public void readUserShouldWorkSuccessfully() {
		RetailAccessObject obj = new RetailDataImp();
		RetailModule product = new RetailModule();
		
		product.setProduct_id(2001);
		product.setProduct_name("DemoName");
		product.setProduct_description("demo description");
		product.setPrice(280);
		obj.create(product);

		RetailModule result = obj.read(2001);
		assertNotNull(result);
		assertEquals("DemoName", result.getProduct_name());
	}
	@Test
	public void readDesciptionUserShouldWorkSuccessfully() {
		RetailAccessObject obj = new RetailDataImp();
		RetailModule product = new RetailModule();
		
		product.setProduct_id(2001);
		product.setProduct_name("DemoName");
		product.setProduct_description("demo description");
		product.setPrice(280);
		obj.create(product);
		RetailModule result = obj.read(2001);
		assertNotNull(result);
		assertEquals("demo description", result.getProduct_description());
	}
	@Test
	public void readPriceUserShouldWorkSuccessfully() {
		RetailAccessObject obj = new RetailDataImp();
		RetailModule product = new RetailModule();
		
		product.setProduct_id(2001);
		product.setProduct_name("DemoName");
		product.setProduct_description("demo description");
		product.setPrice(280);
		obj.create(product);
		RetailModule result = obj.read(2001);
		assertNotNull(result);
		assertEquals(280, result.getPrice());
	}

}

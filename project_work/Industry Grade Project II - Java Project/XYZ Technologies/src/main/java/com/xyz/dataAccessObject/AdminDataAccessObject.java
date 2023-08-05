package com.xyz.dataAccessObject;

import com.xyz.AdminModule;

public interface AdminDataAccessObject {
	void create(AdminModule user);
	AdminModule read(int user_id);
	void delete(AdminModule user);

}

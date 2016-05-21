#include <sourcemod>
#include <dukehacks>

public Plugin:myinfo =
{
	name = "dhtest",
	author = "L. Duke",
	description = "dukehacks extension test",
	version = "0.0.1.0",
	url = "http://www.lduke.com/"
};

public OnPluginStart()
{
	
}


// entity listener
public ResultType:dhOnEntityCreated(edict)
{
	// Working with the edict here (like calling GetEdictClassname) often causes crashes.
	// For most cases, you can use dhOnEntitySpawned instead.
	PrintToConsole(0, "entity CREATED: (id %d)", edict);
	return;
}

// entity listener
public ResultType:dhOnEntitySpawned(edict)
{
	// get class name
	new String:classname[64];
	GetEdictClassname(edict, classname, sizeof(classname)); 
	// print entity class name to console
	PrintToConsole(0, "entity SPAWNED: (id %d) GetEdictClassName: %s", edict, classname);
	return;
}

// entity listener
public ResultType:dhOnEntityDeleted(edict)
{
	// get class name
	new String:classname[64];
	GetEdictClassname(edict, classname, sizeof(classname)); 
	// print entity class name to console
	PrintToConsole(0, "entity DELETED: (id %d) GetEdictClassName: %s", edict, classname);
	return;
}

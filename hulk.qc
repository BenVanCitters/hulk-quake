entity hulkMode;
entity current_hulk;

entity() findNewHulk=
{
	local entity find_ent = find (world, classname, "player");	
	//just go through all players until we find a new one for now, otherwise don't change
	while(find_ent != world)
	{
		if(find_ent != current_hulk)
		{
			//if(find_ent.deadflag == DEAD_NO)
				return find_ent;
		}			
		find_ent = find (find_ent, classname, "player");
	}
	return current_hulk;
}

void(entity newHulk) setHulk=
{
	if(current_hulk)
		current_hulk.effects = current_hulk.effects - (current_hulk.effects & EF_DIMLIGHT);
	current_hulk = newHulk;
	if(current_hulk){
		current_hulk.effects = current_hulk.effects | EF_DIMLIGHT;
		
		//show message for players

		
		bprint(current_hulk.netname);
		bprint(" has become HULK!\n");
	}
}

void() hulkThink=
{
	if(!current_hulk)
		setHulk( findNewHulk() );
	
	hulkMode.think = hulkThink;
	hulkMode.nextthink = time + 3;
}

//creates gametype entity
void() spawnHulk =
{
	//bprint("spawnHulk!\n");
	hulkMode = spawn();
	hulkMode.classname = "hulk_mode";
	hulkMode.think = hulkThink;
	hulkMode.nextthink = time + 10;
}

//wrapper function - to make sure only one per game is created
//maybe even enforce game start requirements
void() spawnHulkMode =
{
	//bprint("trying spawnHulk....\n");
	//only create hulk mode if it doesn't already exist
	local entity hulk = find (world, classname, "hulk_mode");
	if(hulk)
		return;
	spawnHulk();
}



void() HulkSigilTouch =
{
	//bprint("HulkSigilTouch....\n");
	//bprint(other.classname);
	//bprint("\n");
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	
	
	stuffcmd (other, "bf\n");
	//self.solid = SOLID_NOT;
	//other.items = other.items | self.items;
	//self.model = string_null;

	activator = other;	
	remove(self);
	
	setHulk(other);
	sound (other, CHAN_VOICE, self.noise, 1, ATTN_NORM);
};


void() DropHulkSigil =
{
	local entity	item;

	item = spawn();
	item.origin = self.origin - '0 0 24';
	item.netname = "HulkSigil";
	item.velocity_z = 300;
	item.velocity_x = -100 + (random() * 200);
	item.velocity_y = -100 + (random() * 200);
	
	//item.items = IT_HULK;
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	
	setsize (item, '-16 -16 0', '16 16 56');
	setmodel (item, "progs/end1.mdl");
	item.touch = HulkSigilTouch;
	item.noise = "weapons/lock4.wav";
	item.effects = item.effects | EF_DIMLIGHT;
	local entity hulk = find (world, classname, "hulk_mode");
	item.nextthink = hulk.nextthink = time + 30;
	//should it expire? yes - maybe it landed in the lava
	item.think = SUB_Remove;
};


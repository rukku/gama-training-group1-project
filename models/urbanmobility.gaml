/**
 *  urbanmobility
 *  Author: Group1
 *  Description: 
 */

model urbanmobility

global {
	int nb_happy_people<-0 update: people count(each.target=nil);
	int nb_people<-100;
	file roads_hcr_shp <-file("../includes/roads_hypercentreRouen.shp");
	file buildings_hcr_shp<-file("../includes/buildings_hypercentreRouen.shp");
	
	geometry shape<-envelope(buildings_hcr_shp);
	/** Insert the global definitions, variables and actions here */
	graph road_network;
	init{
		step <-1#m;
	
		//create roads from:roads_hcr_shp with:[my_speed::int(read("speed"))];
		create roads from:roads_hcr_shp;
		create buildings from:buildings_hcr_shp with:[my_type::string(read("TYPE"))];
		create people number:nb_people{
			my_buildings<-one_of(buildings where (each.my_type='yes'));
			my_road <- one_of(roads);
			//my_road.nb_drivers <- my_road.nb_drivers + 1;
			location <- any_location_in(my_buildings);
			//office<-one_of(buildings where (each.my_type!='yes'));
			target <- any_location_in(one_of(buildings where (each.my_type!='yes')));
	}
	road_network <-as_edge_graph(roads);
	}
	reflex end_simulaiton when:nb_happy_people=nb_people{
		do pause;}
}

species people skills:[moving]{
	rgb color<-rnd_color(255);
	buildings my_buildings;
	bool is_happy<-false;
//	buildings office;
	roads my_road;
	point target<-nil;
	aspect people_disp{
		draw pyramid(10) color:#yellow;
		draw sphere(12)at:{location.x,location.y,5}color:#yellow;
	} 
	
	
	reflex moving when: target!=nil{
		do goto target:target on:road_network;
		bool is_happy<-false;
		if(location distance_to target.location<10#m){
			target<-nil;
			write "fooo";
			//is_happy<-true;			
		}
		
		//my_road.nb_drivers <- my_road.nb_drivers - 1;
		//my_road <- (road at_distance 10#m) closest_to self;
		//my_road.nb_drivers <- my_road.nb_drivers + 1;
	}
}
species roads{
	aspect geom {
		draw shape color: #gray;
	}
}

species buildings{
	string my_type;
	//buildings k;
	aspect geom {
		if(self.my_type='yes'){
		draw shape color: #blue;}
		else{
			draw shape color: #red;}
		}
		
	}

experiment urbanmobility type: gui {
	/** Insert here the definition of the input and output of the model */
	output {
		monitor "nb of happy people" value: nb_happy_people;
		display map type: opengl{
			species roads aspect:geom;
			species buildings aspect:geom;
			species people aspect: people_disp;
			
	}
}


}

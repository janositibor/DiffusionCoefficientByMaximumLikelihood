function [area] = Mobility_Crawled_area_calculation(struct)
	if(struct.numoflines>2)
		k = boundary(transpose(struct.x_withnulls),transpose(struct.y_withnulls),0);
		area = polyarea(struct.x_withnulls(k),struct.y_withnulls(k));
	else
		area = 0;
	end
end
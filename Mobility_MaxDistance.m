function [output,x1,y1,x2,y2] = Mobility_MaxDistance(struct)
	if(struct.numoflines>2)
		count = 1;
		k = boundary(transpose(struct.x_withnulls),transpose(struct.y_withnulls),0);
		
		x = struct.x_withnulls(k); % x component of coordinate
		y = struct.y_withnulls(k); % y component of coordinate
		
		for i = 1:length(x) - 1
			for j = i + 1:length(x)
			distance(count) = sqrt((x(i) - x(j))^2 + (y(i) - y(j))^2);
			Matrix(count, :) = [x(i) y(i) x(j) y(j) distance(count)];
			count = count + 1;
			end
		end
		SortedMatrix = sortrows(Matrix, 5);
		MaxDis = SortedMatrix(size(Matrix, 1), :);
		output=MaxDis(5);
		x1= MaxDis(1);
		y1= MaxDis(2);
		x2= MaxDis(3);
		y2= MaxDis(4);
	else
		output=0;
		x1= 0;
		y1= 0;
		x2= 0;
		y2= 0;
	end
end
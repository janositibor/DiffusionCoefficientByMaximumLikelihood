function output = Mobility_lhFunction(parameters,R,framelength,dx,dy,varargin)
	if(parameters(1)<0 || parameters(2)<0)
		output=Inf;
	else
		Deltax=dx;
		Deltay=dy;
		D=parameters(1);
		sigma=parameters(2);
		squared_sigma=sigma^2;
		
		data_nr=length(Deltax);
		time_points=(1:data_nr)*framelength;
		
		same=2*D*framelength-2*(R*2*D*framelength-squared_sigma);
		neighbour=R*2*D*framelength-squared_sigma;
		
		same_vector(1:data_nr,1)=same;
		neighbour_vector(1:data_nr-1,1)=neighbour;
		covariance=zeros(data_nr,data_nr)+diag(same_vector)+diag(neighbour_vector,1)+diag(neighbour_vector,-1);
		inverse=inv(covariance);
		determinant=det(covariance);
		
		if (determinant<0)
			output=Inf;
		else
			logdet=log(determinant);
			x_square_perCov=Deltax*inverse*transpose(Deltax);
			y_square_perCov=Deltay*inverse*transpose(Deltay);
			logdet_Z=0;
			z_square_perCov=0;
			if (x_square_perCov<0 || y_square_perCov<0 || z_square_perCov<0)
				output=Inf;
			else
				output=(2*logdet+x_square_perCov+y_square_perCov+logdet_Z+z_square_perCov);
			end
		end
	end
end
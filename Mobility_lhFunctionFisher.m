function output = Mobility_lhFunctionFisher(parameters,R,framelength,dx,dy,varargin)
	
	if(parameters(1)<0 || parameters(2)<0)
		output=Inf;
	else
		Deltax=dx;
		Deltay=dy;
		D=parameters(1);
		sigma=parameters(2);
		square_sigma=sigma^2;
		
		data__nbr=length(Deltax);
		time_steps=(1:data__nbr)*framelength;
		
		fx = fft(Deltax);
		%m = abs(fx);
		mx2=abs(fx).*abs(fx);
		
		fy = fft(Deltay);
		%m = abs(fy);
		my2=abs(fy).*abs(fy);
		
		f = 1:length(fx);
		alfa=2*D*framelength-2*(2*D*R*framelength-square_sigma);
		beta=2*D*R*framelength-square_sigma;
		Fi=alfa+2*beta*cos(2*pi*(f-1)/data__nbr);
		
		MinFi=min(Fi);
		if (min(Fi)<0)
			output=Inf
		else
			assist_vector=2*log(Fi)+(mx2./(data__nbr*Fi))+(my2./(data__nbr*Fi));
			output=sum(assist_vector);
		end
	end
end
function [t, X] = comPete(tspan,Xinit,k,C)
    
    [t, X] = ode45(@ode,tspan,Xinit);
    X = X./sum(Xinit(1:3));

    function dXdt = ode(t,X)
        dXdt = [-k(1)*(C+X(4))*X(1) + k(2)*(X(2)+X(3)); ...
                k(1)*C*X(1) - k(2)*X(2); ...
                k(1)*X(4)*X(1) - k(2)*X(3); ...
                -k(1)*X(4)*X(1) + k(2)*X(3)];
    end
end
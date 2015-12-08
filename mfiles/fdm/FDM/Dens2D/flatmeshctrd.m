function [Phi,Q]=flatmeshctrd(x,y,kx,ky,FH,Q)
% function A=flatmeshctrd(x,y,kx,ky)
% 2D mesh-centred finite difference model
% x,y mesh coordinates, kx,ky conductivities, FH=fixed heads (NaN for normal points) Q=fixed Q
% Phi is computed heads, Q computed nodal balances
%
% TO 990510

HUGE=1e20;

x=x(:)';
y=y(:);

Nx=length(x);
Ny=length(y);

dx=diff(x);
dy=diff(y); if y(end)<y(1), dy=-dy; end

if isempty(FH),  FH=NaN*zeros(Ny,Nx); end; FH=FH(:);
if isempty( Q),   Q=    zeros(Ny,Nx); end;  Q= Q(:);


if size(kx,2)<Nx-1
  kx=[kx,kx(:,end)*ones(1,Nx-1-size(kx,2))];
end
if size(kx,1)<Ny-1
  kx=[kx;ones(Ny-1-size(kx,1),1)*kx(end,:)];
end
if size(ky,2)<Nx-1
  ky=[ky,ky(:,end)*ones(1,Nx-1-size(ky,2))];
end
if size(ky,1)<Ny-1
  ky=[ky;ones(Ny-1-size(ky,1),1)*ky(end,:)];
end

% node numbering
Nodes = reshape([1:Nx*Ny],Ny,Nx);
Il=Nodes(:,2:end);   Jl=Nodes(:,1:end-1);
Ir=Nodes(:,1:end-1); Jr=Nodes(:,2:end);
%Ic=Nodes;            Jc=Nodes;
It=Nodes(2:end,:);   Jt=Nodes(1:end-1,:);
Ib=Nodes(1:end-1,:); Jb=Nodes(2:end,:);

ex= kx.*(dy*ones(size(dx)))./(ones(size(dy))*dx);  ex=0.5*([ex;zeros(1,Nx-1)]+[zeros(1,Nx-1);ex]);
ey= ky.*(ones(size(dy))*dx)./(dy*ones(size(dx)));  ey=0.5*([ey,zeros(Ny-1,1)]+[zeros(Ny-1,1),ey]);

A=-sparse([Il(:);Ir(:);It(:);Ib(:)],...
          [Jl(:);Jr(:);Jt(:);Jb(:)],...
          [ex(:);ex(:);ey(:);ey(:)],Ny*Nx,Ny*Nx,5*Ny*Nx);
Adiag= -sum(A,2);

% Boundary conditions, just Q and Fixed Heads right now

isFxHd=HUGE* ~isnan(FH);
FH(~isFxHd)=0;

Phi=spdiags(isFxHd + ~isFxHd.*Adiag,0,A)\(isFxHd.*FH + ~isFxHd.*Q);

Q=spdiags(Adiag,0,A)*Phi;

Q  =reshape(Q,Ny,Nx);
Phi=reshape(Phi,Ny,Nx);
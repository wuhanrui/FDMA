function [Ms, Mt, Mst, Mts] = constructMMD(ns,nt)
e = [1/ns*ones(ns,1);-1/nt*ones(nt,1)];
es = 1/ns*ones(ns,1);
et = -1/nt*ones(nt,1);

M = e*e';
Ms = es*es';
Mt = et*et';
Mst = es*et';
Mts = et*es';
% if ~isempty(Yt0) && length(Yt0)==nt
%     for c = reshape(unique(Ys),1,C)
%         es = zeros(ns,1);
%         et = zeros(nt,1);
%         es(Ys==c) = 1/length(find(Ys==c));
%         et(Yt0==c) = -1/length(find(Yt0==c));
%         es(isinf(es)) = 0;
%         et(isinf(et)) = 0;
%         Ms = Ms + es*es';
%         Mt = Mt + et*et';
%         Mst = Mst + es*et';
%         Mts = Mts + et*es';
%     end
% end

Ms = Ms/norm(M,'fro');
Mt = Mt/norm(M,'fro');
Mst = Mst/norm(M,'fro');
Mts = Mts/norm(M,'fro');
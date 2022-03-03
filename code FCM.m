	clc; clear all
k=input('Masukkan Jumlah Maksimal Percobaan Cluster: ')
data=load('datahighwaskitajan.txt');
it=2;
f(1)=0;
while it<k+1
[center,U,objFcn]=fcm(data,it);
plot(objFcn);
%%  Penghitungan Partition Coefficient (PC)
A=U.^2;
sum(A(:));
f(it)=(sum(A(:)))/length(data);
it=it+1;
end
disp('Hasil PC Seluruh Percobaan')
x=f
[maxxf,idk]=max(f);
disp(['Jumlah Cluster Optimal ' num2str(idk)]);
disp(['Nilai PC Terbesar diperoleh sebesar ' num2str(maxxf)]);
[center,U,objFcn]=fcm(data,idk);
disp('Pusat Cluster yang diperoleh');
disp(center);
disp('Nilai Keanggotaan Cluster');
disp(max(U));
disp('Menampilkan Anggota Kelompok Setiap Cluster');
for i=1:idk
    disp(['Anggota cluster ke-' num2str(i)])
    disp(num2str(find(U(i,:)==max(U))))
end
plot(objFcn)
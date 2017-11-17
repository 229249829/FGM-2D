function  FGM_2D( file_in )
% ��������̬�¶ȳ�2016��5��5�����Ͼŵ����
%      2D-FGM( filename )
%  ��������� 
%      file_in  ---------- ����Ԫģ���ļ�

% ����ȫ�ֱ���
%      gNode ------------- �ڵ�����
%      gElement ---------- ��Ԫ����
%      gK ---------------- ����նȾ���
%      gDelta ------------ ����ڵ�����
%      gNodeStress ------- �ڵ�Ӧ��
%      gElementStress ---- ��ԪӦ��
%      gnode_1st-----------��һ�߽�ڵ��
%      gnode_2nd-----------�ڶ��߽�ڵ��
%      gnode_3th-----------�����߽�ڵ��

    global gNode gElement  gK gP TDelta  gnode_1st gnode_2nd gnode_3th

    if nargin < 1
        file_in = 'SaveAllDate.txt' ;
    end
    
        % ��������Ԫģ�Ͳ���⣬������
        FemModel( file_in ) ;          % ��������Ԫģ��
        [element_number,dummy] = size( gElement );      %ȡ����Ԫ�ܸ���
        for   ie=1:1:element_number 
        gElementTurn(ie);               %ת����Ԫ�ڵ���������ݣ����临�ϵ�һ������߽�����jm���ڱ߽�Ĺ���
        end
        TTT=SolveModel ;                   % �������Ԫģ��
% �������
%     disp( sprintf( '������������������������ļ� %s ��', file_out ) ) ;
%     disp( sprintf( '����ʹ�ú������ exam4_2_post.m ��ʾ������' ) ) ;
return

function FemModel(filename)
%  ��������Ԫģ��
%  ���������
%      filename --- ����Ԫģ���ļ�
%  ����ֵ��
%      ��
%  ˵����
%      �ú�������ƽ�����������Ԫģ�����ݣ�
%        gNode ------- �ڵ㶨��
%        gElement ---- ��Ԫ����
%        gMaterial --- ���϶��壬��������ģ�������Ľ���������Ŀ�����Ծ�
%        gBC1 -------- Լ������

    global gNode gElement  gBC1 gnode_1st gnode_2nd gnode_3th
    
    % ���ļ�
    fid = fopen( filename, 'r' ) ;
    
    % ��ȡ�ڵ�����
    node_number = fscanf( fid, '%d', 1 ) ;
    gNode = zeros( node_number, 2 ) ;
    for i=1:node_number
        dummy = fscanf( fid, '%d', 1 ) ;
        gNode( i, : ) = fscanf( fid, '%f', [1, 2] ) ;
    end
    
    % ��ȡ��Ԫ����
    element_number = fscanf( fid, '%d', 1 ) ;
    gElement = zeros( element_number, 3 ) ;
    for i=1:element_number
        dummy = fscanf( fid, '%d', 1 ) ;
        gElement( i, : ) = fscanf( fid, '%d', [1, 3] ) ;
    end
    %��ȡ��һ��߽�ڵ�
    Nnode_1st = fscanf( fid, '%d', 1 ) ;
    gnode_1st = zeros( Nnode_1st, 1 ) ;
    for i=1:Nnode_1st
        
        gnode_1st( i ) = fscanf( fid, '%d', 1) ;
    end
    %��ȡ�ڶ���߽�ڵ�
    Nnode_2nd = fscanf( fid, '%d', 1 ) ;
    gnode_2nd = zeros( Nnode_2nd, 1 ) ;
    for i=1:Nnode_2nd
        
        gnode_2nd( i ) = fscanf( fid, '%d', 1) ;
    end
    %��ȡ������߽�ڵ�
    Nnode_3th = fscanf( fid, '%d', 1 ) ;
    gnode_3th = zeros( Nnode_3th, 1 ) ;
    for i=1:Nnode_3th
        
        gnode_3th( i ) = fscanf( fid, '%d', 1) ;
    end
  
   
    % �ر��ļ�
    fclose( fid ) ;
return


function TTT=SolveModel
%  �������Ԫģ��
%  ���������
%     ��
%  ����ֵ��
%     ��
%  ˵����
%      �ú����������Ԫģ�ͣ���������
%        1. ���㵥Ԫ�նȾ��󣬼�������նȾ���
%        2. ���㵥Ԫ�ĵ�Ч�ڵ�������������ڵ�������
%        3. ����Լ���������޸�����նȾ���ͽڵ�������
%        4. ��ⷽ���飬�õ�����ڵ�λ������
%        5. ���㵥ԪӦ���ͽڵ�Ӧ��

    global gNode gElement  gBC1 gK gP TDelta   gnode_1st gnode_2nd gnode_3th
    fidoutdate = fopen( 'Outdate.txt', 'w' ) ;

    % step1. ��������նȾ���ͽڵ�������
    [node_number,dummy] = size( gNode ) ;
    gK = sparse( node_number , node_number ) ;
    gP = sparse( node_number , 1 ) ;

    % step2. ���㵥Ԫ�նȾ��󣬲����ɵ�����նȾ�����
    [element_number,dummy] = size( gElement ) ;
    for ie=1:1:element_number
        disp( sprintf(  '����նȾ��󣬵�ǰ��Ԫ: %d', ie  ) ) ;
        k = StiffnessMatrix( ie ) ;
        AssembleStiffnessMatrix( ie, k ) ;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %�����Ҳ������� P
%     function p = PonclusionP(ie)
    for ie=1:1:element_number
        disp( sprintf(  '�����Ҳ������� P����ǰ��Ԫ: %d', ie  ) ) ;
        p = PonclusionP(ie) ;
        AssembleP( ie, p) ;
    end
     % %     % step4. ����Լ���������޸ĸնȾ���ͽڵ������������ó˴����� 
        [bc_number,dummy] = size( gnode_1st ) ;
         for ibc=1:1:bc_number
             n = gnode_1st (ibc, 1 ) ;
         
             gP(n) = 300* gK(n,n) * 1e12 ;%����߽��¶ȴ˴�Ϊ����300K                         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��һ��߽��¶���
             gK(n,n) = gK(n,n) * 1e12;
         end
    % step 5. ��ⷽ���飬�õ��ڵ��¶�����
    TDelta = gK \ gP ;
    TTT=full(TDelta);
    TTT=TTT';
    
    fprintf( fidoutdate,'%f\n',TTT );
    fclose(fidoutdate);
 
return









function gElementTurn(ie)   %ת����Ԫ�ڵ���������ݣ����临�ϵ�һ������߽�����jm���ڱ߽�Ĺ���
        global  gElement gNode gnode_1st gnode_2nd gnode_3th%����ȫ�ֱ���
        [NgElement,dummy] = size( gElement ) ;
        [Nnode_1st,dummy] = size( gnode_1st ) ;  %ȡ����һ��߽�ڵ�ŵĸ���
        [Nnode_2nd,dummy] = size( gnode_2nd ) ;  %ȡ���ڶ���߽�ڵ�ŵĸ���
        [Nnode_3th,dummy] = size( gnode_3th) ;  %ȡ��������߽�ڵ�ŵĸ���
        %�ж��Ƿ�Ϊ��һ��߽絥Ԫ  ����ǵ�һ��߽絥Ԫ����ô��Ԫ�ϱ����������ڵ��ڵ�һ��߽�ڵ�����ômΪ2��   
        m=0;
        for i=1:3
            for j=1:Nnode_1st
               if(gElement( ie, i )==gnode_1st(j))
                   m=m+1;
               end
            end
        end
        if (m==2)
                   %�ж��Ǹ������ڵ�Ϊj��m
                    m=0;
                    for i=1:3
                          for j=1:Nnode_1st
                           if(gElement( ie, i )==gnode_1st(j))
                               m=m+1;
                               if(m==1)
                                   j_1st=gElement( ie, i );
                               end
                               if(m==2)
                                   m_1st=gElement( ie, i );
                               end
                           end
                        end
                    end
                    %�ж�����Ϊi�ĵ�
                    for i=1:3
                        if(~(gElement( ie, i )==j_1st|m_1st==gElement( ie, i )))
                            i_1st=gElement( ie, i );
                        end
                    end
                     gElement( ie, 1 )=i_1st;
                     gElement( ie, 2 )=j_1st;
                     gElement( ie, 3 )=m_1st;
        end
        %�ж��Ƿ�Ϊ�ڶ���߽絥Ԫ  ����ǵڶ���߽絥Ԫ����ô��Ԫ�ϱ����������ڵ��ڵڶ���߽�ڵ�����ômΪ2��   
        m=0;
        for i=1:3
            for j=1:Nnode_2nd
               if(gElement( ie, i )==gnode_2nd(j))
                   m=m+1;
               end
            end
        end
        if (m==2)
                   %�ж��Ǹ������ڵ�Ϊj��m
                    m=0;
                    for i=1:3
                          for j=1:Nnode_2nd
                           if(gElement( ie, i )==gnode_2nd(j))
                               m=m+1;
                               if(m==1)
                                   j_2nd=gElement( ie, i );
                               end
                               if(m==2)
                                   m_2nd=gElement( ie, i );
                               end
                           end
                        end
                    end
                    %�ж�����Ϊi�ĵ�
                    for i=1:3
                        if(~(gElement( ie, i )==j_2nd|m_2nd==gElement( ie, i )))
                            i_2nd=gElement( ie, i );
                        end
                    end
                     gElement( ie, 1 )=i_2nd;
                     gElement( ie, 2 )=j_2nd;
                     gElement( ie, 3 )=m_2nd;
        end
                %�ж��Ƿ�Ϊ������߽絥Ԫ  ����ǵ�����߽絥Ԫ����ô��Ԫ�ϱ����������ڵ��ڵ�����߽�ڵ�����ômΪ2��   
        m=0;
        for i=1:3
            for j=1:Nnode_3th
               if(gElement( ie, i )==gnode_3th(j))
                   m=m+1;
               end
            end
        end
        if (m==2)
                   %�ж��Ǹ������ڵ�Ϊj��m
                    m=0;
                    for i=1:3
                          for j=1:Nnode_3th
                           if(gElement( ie, i )==gnode_3th(j))
                               m=m+1;
                               if(m==1)
                                   j_3th=gElement( ie, i );
                               end
                               if(m==2)
                                   m_3th=gElement( ie, i );
                               end
                           end
                        end
                    end
                    %�ж�����Ϊi�ĵ�
                    for i=1:3
                        if(~(gElement( ie, i )==j_3th|m_3th==gElement( ie, i )))
                            i_3th=gElement( ie, i );
                        end
                    end
                     gElement( ie, 1 )=i_3th;
                     gElement( ie, 2 )=j_3th;
                     gElement( ie, 3 )=m_3th;
        end
    


return











function k = StiffnessMatrix( ie )
%  ���㵥Ԫ�նȾ���
%  �������:
%     ie ----  ��Ԫ��
%  ����ֵ:
%     k  ----  ��Ԫ�նȾ���
  
    
    global gNode gnode_3th gElement %gMaterial 
   
    [Nnode_3th,dummy] = size( gnode_3th ) ; %ȡ��������߽�ڵ�ŵĸ���
%�ж��Ƿ�Ϊ������߽絥Ԫ  ����ǵ�����߽絥Ԫ����ô��Ԫ�ϱ����������ڵ��ڵ�����߽�ڵ�����ômΪ2��
    m=0;
    for i=1:3
        for j=1:Nnode_3th
           if(gElement( ie, i )==gnode_3th(j))
               m=m+1;
               
           end
        end
    end
%����ж�Ϊ������߽�����������������
    if(m==2)
                
                
                 k = zeros( 6, 6 ) ;
            %    E  = gMaterial( gElement(ie, 4), 1 ) ;
            %   mu = gMaterial( gElement(ie, 4), 2 ) ;
            %    h  = gMaterial( gElement(ie, 4), 3 ) ;
                xi = gNode( gElement( ie, 1 ), 1 ) ;
                yi = gNode( gElement( ie, 1 ), 2 ) ;
                xj = gNode( gElement( ie, 2 ), 1 ) ;
                yj = gNode( gElement( ie, 2 ), 2 ) ;
                xm = gNode( gElement( ie, 3 ), 1 ) ;
                ym = gNode( gElement( ie, 3 ), 2 ) ;
                xaverage=(xi+xj+xm)/3;
                yaverage=(yi+yj+ym)/3;
                
            %���㵼��ϵ�����⵼��ϵ��c=d=0.1��
               % kconduct=exp(xaverage*0.1+yaverage*0.1);
               %ansys��֤
              % kconduct=1;%�ȵ���
               kconduct=10*exp(xaverage*10+yaverage*10);%c=d=0.1ʱ
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%������
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    k=D*exp(cx+dy)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    D=1
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%()
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% kconduct=exp(xaverage*0.1+yaverage*0.1);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%kconduct=exp(xaverage*0.1+yaverage*0.1);

                ai = xj*ym - xm*yj ;
                aj = xm*yi - xi*ym ;
                am = xi*yj - xj*yi ;
                bi = yj - ym ;
                bj = ym - yi ;
                bm = yi - yj ;
                ci = -(xj-xm) ;
                cj = -(xm-xi) ;
                cm = -(xi-xj) ;
                area = ElementArea( ie ) ;
                fi=kconduct/area/4; %fiΪϵ����
                k=zeros(3,3);
                %siΪjm�߳�
                si=sqrt(bi^2+ci^2);
                %hconΪ����ϵ��
                hcon=10*exp(10*((xj+xm)/2)) %h%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%�ϱ߽绻��ϵ�������仯h0=1��h=h0exp(cx)
                k(1,1)=fi*(bi^2+ci^2);
                k(2,2)=fi*(bj^2+cj^2)+hcon*si/3;
                k(3,3)=fi*(bm^2+cm^2)+hcon*si/3;
                k(1,2)=fi*(bi*bj+ci*cj);
                k(2,1)=fi*(bi*bj+ci*cj);
                k(1,3)=fi*(bi*bm+ci*cm);
                k(3,1)=fi*(bi*bm+ci*cm);
                k(2,3)=fi*(bj*bm+cj*cm)+hcon*si/6;
                k(3,2)=fi*(bj*bm+cj*cm)+hcon*si/6;

                   
    end
    %����ǵ�����߽絥Ԫ�����³����
    if(m<2)
    k = zeros( 6, 6 ) ;
%    E  = gMaterial( gElement(ie, 4), 1 ) ;
%   mu = gMaterial( gElement(ie, 4), 2 ) ;
%    h  = gMaterial( gElement(ie, 4), 3 ) ;
    xi = gNode( gElement( ie, 1 ), 1 ) ;
    yi = gNode( gElement( ie, 1 ), 2 ) ;
    xj = gNode( gElement( ie, 2 ), 1 ) ;
    yj = gNode( gElement( ie, 2 ), 2 ) ;
    xm = gNode( gElement( ie, 3 ), 1 ) ;
    ym = gNode( gElement( ie, 3 ), 2 ) ;
    xaverage=(xi+xj+xm)/3;
    yaverage=(yi+yj+ym)/3;
%���㵼��ϵ�����⵼��ϵ��c=d=0.1��
   % kconduct=exp(xaverage*0.1+yaverage*0.1);
     %kconduct=1;%�ȵ���%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%������
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     k=exp(cx +dy)
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     kconduct=10*exp(xaverage*10+yaverage*10);%c=d=0.1ʱ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    ai = xj*ym - xm*yj ;
    aj = xm*yi - xi*ym ;
    am = xi*yj - xj*yi ;
    bi = yj - ym ;
    bj = ym - yi ;
    bm = yi - yj ;
    ci = -(xj-xm) ;
    cj = -(xm-xi) ;
    cm = -(xi-xj) ;
    area = ElementArea( ie );
    fi=kconduct/area/4;
    k=zeros(3,3);
    k(1,1)=fi*(bi^2+ci^2);
    k(2,2)=fi*(bj^2+cj^2);
    k(3,3)=fi*(bm^2+cm^2);
    k(1,2)=fi*(bi*bj+ci*cj);
    k(2,1)=fi*(bi*bj+ci*cj);
    k(1,3)=fi*(bi*bm+ci*cm);
    k(3,1)=fi*(bi*bm+ci*cm);
    k(2,3)=fi*(bj*bm+cj*cm);
    k(3,2)=fi*(bj*bm+cj*cm);
    end
 %   B = [bi  0 bj  0 bm  0
 %         0 ci  0 cj  0 cm
 %        ci bi cj bj cm bm] ;
 %   B = B/2/area ;
 %   D = [ 1-mu    mu      0
 %          mu    1-mu     0
 %           0      0   (1-2*mu)/2] ;
 %   D = D*E/(1-2*mu)/(1+mu) ;
 %  k = transpose(B)*D*B*h*abs(area) ;    
return



function area = ElementArea( ie )
%  ���㵥Ԫ���
%  �������:
%     ie ----  ��Ԫ��
%  ����ֵ:
%     area  ----  ��Ԫ���
    global gNode gElement gMaterial 

    xi = gNode( gElement( ie, 1 ), 1 ) ;
    yi = gNode( gElement( ie, 1 ), 2 ) ;
    xj = gNode( gElement( ie, 2 ), 1 ) ;
    yj = gNode( gElement( ie, 2 ), 2 ) ;
    xm = gNode( gElement( ie, 3 ), 1 ) ;
    ym = gNode( gElement( ie, 3 ), 2 ) ;
    ai = xj*ym - xm*yj ;
    aj = xm*yi - xi*ym ;
    am = xi*yj - xj*yi ;
    area = abs((ai+aj+am)/2)  ;
return

function AssembleStiffnessMatrix( ie, k )
%  �ѵ�Ԫ�նȾ��󼯳ɵ�����նȾ���
%  �������:
%      ie  --- ��Ԫ��
%      k   --- ��Ԫ�նȾ���
%  ����ֵ:
%      ��
    global gElement gK
    for i=1:1:3
        for j=1:1:3               
                    M = gElement(ie,i) ;
                    N = gElement(ie,j) ;
                    gK(M,N) = gK(M,N) + k(i,j) ;                
        end
    end
return

%����P����������
function p = PonclusionP(ie )   
%      ie  ----- ��Ԫ��
         global   gElement gNode   gnode_1st  gnode_2nd   gnode_3th
         p=zeros(3,1);
         for i=1:3
            p(i,1)=0;%p�����ʼ��
         end
         [Nnode_1st,dummy] = size( gnode_1st ) ;  %ȡ����һ��߽�ڵ�ŵĸ���
         [Nnode_2nd,dummy] = size( gnode_2nd ) ;  %ȡ���ڶ���߽�ڵ�ŵĸ���
         [Nnode_3th,dummy] = size( gnode_3th) ;  %ȡ��������߽�ڵ�ŵĸ���         
         %�ж��Ƿ�Ϊ��һ��߽絥Ԫ  ����ǵ�һ��߽絥Ԫ����ô��Ԫ�ϱ����������ڵ��ڵ�һ��߽�ڵ�����ômΪ2��   
        m=0;
        for i=1:3
            for j=1:Nnode_1st
               if(gElement( ie, i )==gnode_1st(j))
                   m=m+1;
               end
            end
        end
        if (m==2)
            for i=1:3
            p(i,1)=0;%�˴�������Դ����Ϊ�㣬������ӵ�һ��߽��µ�����Դ���ο����26ҳ
            end
        end
          
         %�ж��Ƿ�Ϊ�� ����߽絥Ԫ  ����ǵڶ���߽絥Ԫ����ô��Ԫ�ϱ����������ڵ��ڵڶ���߽�ڵ�����ômΪ2��       
        m=0;
        for i=1:3
            for j=1:Nnode_2nd
               if(gElement( ie, i )==gnode_2nd(j))
                   m=m+1;
               end
            end
        end
        if (m==2)             
                xi = gNode( gElement( ie, 1 ), 1 ) ;
                yi = gNode( gElement( ie, 1 ), 2 ) ;
                xj = gNode( gElement( ie, 2 ), 1 ) ;
                yj = gNode( gElement( ie, 2 ), 2 ) ;
                xm = gNode( gElement( ie, 3 ), 1 ) ;
                ym = gNode( gElement( ie, 3 ), 2 ) ;
                bi = yj - ym ;
                ci = -(xj-xm) ;
                %siΪjm�߳�
                si=sqrt(bi^2+ci^2);
                %qflux=100*((xj+xm)/2)^2     %��ͨ���ĺ���������Ϊx�����ϱ߽�
                p(1,1)=0;%�˴�������Դ����Ϊ�㣬������ӵ�һ��߽��µ�����Դ���ο����26ҳ
                p(2,1)=0.5*(-500000000*(xj)^2+10000000*xj+100000)*si;%10.0*(xj)^2�˴�������Դ����Ϊ�㣬������ӵ�һ��߽��µ�����Դ���ο����26ҳ
                p(3,1)=0.5*(-500000000*(xm)^2+10000000*xm+100000)*si;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��ͨ��q=Ex^2+Fx+G
        end
 
        %�ж��Ƿ�Ϊ�� ����߽絥Ԫ  ����ǵ�����߽絥Ԫ����ô��Ԫ�ϱ����������ڵ��ڵ�����߽�ڵ�����ômΪ2��       
        m=0;
        for i=1:3
            for j=1:Nnode_3th
               if(gElement( ie, i )==gnode_3th(j))
                   m=m+1;
               end
            end
        end
        if (m==2)
                    xi = gNode( gElement( ie, 1 ), 1 ) ;
                    yi = gNode( gElement( ie, 1 ), 2 ) ;
                    xj = gNode( gElement( ie, 2 ), 1 ) ;
                    yj = gNode( gElement( ie, 2 ), 2 ) ;
                    xm = gNode( gElement( ie, 3 ), 1 ) ;
                    ym = gNode( gElement( ie, 3 ), 2 ) ;
                    xaverage=(xi+xj+xm)/3;
                    
                    bi = yj - ym ;
                    ci = -(xj-xm) ;
                    %siΪjm�߳�
                    si=sqrt(bi^2+ci^2);
                    %hconΪ����ϵ��
                    
                    
                    hcon=10*exp(10*((xj+xm)/2));%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %hconΪ����ϵ��
                   
                    
                    
                    p(1,1)=0;%�˴�������Դ����Ϊ�㣬������ӵ�һ��߽��µ�����Դ���ο����26ҳ
                    p(2,1)=0.5*hcon*si*(1000*sin(xj*pi/0.02)+300);%�˴�������Դ����Ϊ�㣬������ӵ�һ��߽��µ�����Դ���ο����26ҳ
                    p(3,1)=0.5*hcon*si*(1000*sin(xm*pi/0.02)+300);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%TF=300*sin(xm*pi/20)+300
        end
 
return


function AssembleP (ie, p) 
%  �ѵ�ԪP���ɵ�����P
%  �������:
%      ie  --- ��Ԫ��
%      p  --- ��Ԫp����
%  ����ֵ:
%      ��
    global gElement   gP
    for i=1:1:3
                    M = gElement(ie,i) ;                    
                    gP(M,1) = gP(M,1) + p(i,1) ;
    end
    
return



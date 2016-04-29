infile = 'web-Google.txt';
if ~exist('data','var')
    data = load(infile, '-ascii');
    a = data(:,1); % column 1 of the data text file is assigned the variable x
    b = data(:,2); % column 2 is assigned the variable y
    a = uint32(a);
    b = uint32(b);
    a=a+1;
    b=b+1;
    a=transpose(a);
    b=transpose(b);
    vec_len=length(a);
    n=916428;
    no_workers=2;
    for i=1:vec_len
        G(1,i)=a(i);
        G(2,i)=b(i);
    end
    con_size = zeros(n,1,'uint32');
    L = zeros(n,460,'uint32');
    for j = 1:vec_len
        from_idx=a(j);
        con_size(from_idx)=con_size(from_idx)+1;
        L(from_idx,con_size(from_idx))=b(j);
    end
end

% Power method
p = .85;
delta = (1-p)/n;

chunk_size = floor(n/no_workers);
r = rem(n,no_workers);
thresh = .0001;
% Parallel portion
hp = gcp('nocreate');
if ~isempty(hp)
    delete(hp);
end
parpool(no_workers);
tic
spmd
    cnt = 0;
    start_index = 1 + (labindex-1)*chunk_size;
    if((labindex-1)<r)
        start_index=start_index+labindex-1;
    else
        start_index=start_index+r;
    end
    end_index = start_index + chunk_size;
    if((labindex-1)<r)
        end_index=end_index+1;
    end
    end_index=end_index-1;
    p_t1 = ones(n,1)/n;
    max_error=100;
    glob_max_error = max_error;
    p_t1_sum = zeros(n,1);
    print2=zeros(n,1);
    print1=zeros(6,460);
    print3=zeros(n,1);
    print4=zeros(n,1);
    print5=zeros(n,1);
    constant=0.001;
    constant1=0.0001;
    size=1;
    sizes=ones(n,1);
    sizes=con_size;
end

spmd
    while (glob_max_error>thresh)
        p_t0 = p_t1;
        p_t1 = zeros(n,1);
        
        for j = start_index:end_index
            
            %constant=double(p_t0(j))/double(con_size(j));
            constant=double(p_t0(j))/double(sizes(j));
            constant1=p_t0(j)/n;
            if con_size(j) == 0 % not connected to any other website
                p_t1 = p_t1 + constant1;
            else
                for i=1:con_size(j)
                    p_t1(L(j,i)) = p_t1(L(j,i)) +constant;
                    print1(j,i)=p_t1(L(j,i));
                end
            end
        end
        p_t1_DELETE=p_t1;
        p_t1_sum=gplus(p_t1);
        p_t1=p_t1_sum;
        p_t1 = p*p_t1 + delta;
        cnt = cnt+1;
        max_error= max(abs(p_t1-p_t0));
        glob_max_error = gop(@max,max_error);
        
    end
    labBarrier;
end
toc

delete(gcp)



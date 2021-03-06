function [genetic_man, fitness] = genetic_route(num_city,city_distances,p,max_dist,population_count,generation_count,threshold_mutate)
    %Genetic Algorithm approach is used to calculate a feasible solution to
    %the TSP, finally comparing with other solutions
    
    %Check matrix equal function
    function [flag] = check(ref,base_ref)
        flag=1;
        for var30=1:num_city
            if(ref(var30)~=base_ref(var30))
                flag=0;
                return;
            end
        end
    end
    
    %Validation function
    function [verified] = validate(chromo)
        if (numel(unique(chromo))==numel(chromo))
            verified=chromo;
            return;
        end
        
        reference=zeros(1,num_city);
        base_reference=ones(1,num_city);

        for var21=1:num_city
            reference(chromo(var21))=reference(chromo(var21))+1;
        end
        while (~check(reference,base_reference))
            duplicates=find(reference>1);
            not_present=find(reference==0);
            replace=find(chromo==duplicates(1));
            replacement=not_present(1);
            reference(chromo(replace(1)))=reference(chromo(replace(1)))-1;
            chromo(replace(1))=replacement;
            reference(replacement)=reference(replacement)+1;
        end
        verified=chromo;
    end
    
    %Fitness function
    function [value] = calc_fitness(chromo)
        value=0;
        for i=1:num_city-1
            value=value+city_distances(chromo(i),chromo(i+1));
        end
        value=(value*10^(-log10(max_dist))^-1);
    end
    
    %Eligibility function
    function [flag] = iseligible(updated_population,member)
        flag=1;
        for var2=1:population_count
            if (updated_population(var2,:)==member)
                flag=0;return;
            end
        end
    end
    
    %%Initial Declarations, controlling variables
    %population_count must be <=factorial(num_city)
    %population_count=2;%May be experimented with, for instance, factorial(num_city-1)
    if(population_count>factorial(num_city))
        display('Population count must be <= factorial(num_city).');
        return;
    end
    %generation_count=2;%May be experimented with
    %threshold_mutate=1;%Mutation threshold, higher threshold=higher mutation rate
    
    num_sectors=population_count*50;
    num_rows=size(p);%Needs Optimization
    random_individuals=randi([1 num_rows(1)],population_count,1);
    population=zeros(population_count,num_city);
    updated_population=zeros(population_count,num_city);
    index=zeros(6,1);
    fitness_database=zeros(population_count,generation_count);
    
    %Initial Population Seed
    for var3=1:population_count
        for jar1=1:num_city
            population(var3,jar1)=p(random_individuals(var3),jar1);
        end
    end
    
    
    %Begin Epoch Generation
    for epoch=1:generation_count
        
        for var1=1:population_count
            fitness_database(var1,epoch)=calc_fitness(population(var1,:));
        end
        
        %Select individuals for breeding on basis of fitness
        %Higher fitness=Higher breeding chances
        sum_fitness=sum(fitness_database(:,epoch));
        probab_mating=ones(population_count,2);
        for var4=1:population_count
            probab_mating(var4,1)=fitness_database(var4,epoch)./sum_fitness;
        end
        
        for var5=1:population_count
            probab_mating(var5,2)=num_sectors*probab_mating(var5,1);
        end
        
        for var6=1:population_count
            probab_mating(var6,2)=round(probab_mating(var6,2));
        end
        
        if(sum(probab_mating(:,2)~=num_sectors))
            display('Adjusting sectors for calculations.');
            num_sectors=sum(probab_mating(:,2));
        end
        sector_table=zeros(num_sectors,2);
        for var7=1:num_sectors
            sector_table(var7,1)=var7;
        end
        jar2=1;
        for var8=1:population_count
            for jar2=jar2:jar2+probab_mating(var8,2)
                sector_table(jar2,2)=var8;
            end
        end
        heavyweight=max(probab_mating(:,2));
        
        %Crossover function
        display('Crossing Over.');
        select1=4;
        select2=5;
        while(abs(select1-select2<=heavyweight))
            select1=randi([1 num_sectors]);
            select2=randi([1 num_sectors]);
        end
        indiv1=population(sector_table(select1,2),:);
        indiv1=validate(indiv1);
        indiv2=population(sector_table(select2,2),:);
        indiv2=validate(indiv2);
        cutpoint=round(num_city/2);
        offspring1=[indiv1(1:cutpoint) indiv2(cutpoint+1:num_city)];
        offspring1=validate(offspring1);
        offspring2=[indiv1(1:cutpoint) indiv2(1:cutpoint)];
        offspring2=validate(offspring2);
        offspring3=[indiv1(cutpoint+1:num_city) indiv2(cutpoint+1:num_city)];
        offspring3=validate(offspring3);
        offspring4=[indiv1(cutpoint+1:num_city) indiv2(1:cutpoint)];
        offspring4=validate(offspring4);
        index(1)=calc_fitness(indiv1);
        index(2)=calc_fitness(indiv2);
        index(3)=calc_fitness(offspring1);
        index(4)=calc_fitness(offspring2);
        index(5)=calc_fitness(offspring3);
        index(6)=calc_fitness(offspring4);
        prodigy1=find(index==(max(index)));
        index(prodigy1)=0.01;
        prodigy2=find(index==(max(index)));
        switch (prodigy1(1))
            case 1
                updated_population(1,:)=indiv1;
            case 2
                updated_population(1,:)=indiv2;
            case 3
                updated_population(1,:)=offspring1;
            case 4
                updated_population(1,:)=offspring2;
            case 5
                updated_population(1,:)=offspring3;
            case 6
                updated_population(1,:)=offspring4;
        end
        switch (prodigy2(1))
            case 1
                updated_population(2,:)=indiv1;
            case 2
                updated_population(2,:)=indiv2;
            case 3
                updated_population(2,:)=offspring1;
            case 4
                updated_population(2,:)=offspring2;
            case 5
                updated_population(2,:)=offspring3;
            case 6
                updated_population(2,:)=offspring4;
        end
        for var9=3:population_count
            eligible=0;
            safety_check=0;
            while((~eligible)&&(safety_check~=100))
                select1=randi([1 num_sectors]);
                member=population(sector_table(select1,2),:);
                eligible=iseligible(updated_population,member);
                safety_check=safety_check+1;
            end
            updated_population(var9,:)=member;
        end
        
        %Mutation function
        display('Mutating.');
        chance=randi([1 1000]);
        if (chance>threshold_mutate)
            x=randi([1 population_count]);
            y=randi([1 num_city],2,1);
            swapper=updated_population(x,y(1));
            updated_population(x,y(1))=updated_population(x,y(2));
            updated_population(x,y(1))=swapper;
        end
        population=updated_population
        fitness_database
    end
    akshish=1:generation_count;
    figure
    hold on
    plot(akshish,mean(fitness_database),'r*--');
    plot(akshish,max(fitness_database),'b*--');
    plot(akshish,min(fitness_database),'g*--');
    xlabel('Generations');
    ylabel('Fitness');
    title('Fitness parameters with successive generations');
    legend('Average Fitness','Maximum Fitness','Minimum Fitness');
    best_chromosome=max(find(fitness_database==max(max(fitness_database))));
    showstopper=mod(best_chromosome,population_count);
    if ~(showstopper) 
        showstopper=population_count;
    end
    genetic_man=population(showstopper,:);
    fitness=calc_fitness(genetic_man);
end


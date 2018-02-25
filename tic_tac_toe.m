function tic_tac_toe

    % A program that plays tic tac toe.
    % Daniel W. Dichter
    % 24-Feb-2018
    
    % Board state:
    % 3-by-3 matrix
    % 0: blank
    % 1: X
    % 2: O
    
    %% User inputs
    
    % Player configuration
    % Column 1: 1 for X, 2 for O
    % Column 2: 1 to move first, 2 to move second
    pc = [1, 1];
    
    ctl = 2.5; % s, computer time limit on moves
    lw = 1.5; % line width
    ls = 40; % letter size
    wlc = zeros(1,3) + 0.6; % win line color
    
    %% Setup
    
    clc
    
    % Define colormap for visualizing computer value function
    cmr = 256; % colormap resolution
    cm = [ % define colormap limits
            238 44 44 % red
            50 205 50 % green
         ]/255;
     cm = [linspace(cm(1),cm(2),cmr)', linspace(cm(3),cm(4),cmr)', linspace(cm(5),cm(6),cmr)']; % interpolate for higher resolution
     cm = [zeros(1,3) + 0.6; cm]; % append gray
    
    B = zeros(3); % initialize board
    
%     B = [ % test to see if computer will make a winning move if it can also block
%             1 2 0
%             0 2 0
%             1 0 0
%         ];

%     B = [ % test to see how computer evaluates multiple winning paths
%             1 0 2
%             2 2 0
%             1 0 1
%         ];

%     B = [ % test to see if computer can avert a double-pronged attack
%             0 0 2
%             0 1 0
%             2 0 0
%         ];

%     B = [ % test with two simultaneous win paths: horizontal and vertical
%             0 2 2
%             2 1 1
%             2 1 1
%         ];

%     B = [ % test with two simultaneous win paths: vertical and diagonal
%             2 1 2
%             1 0 1
%             2 1 2
%         ];
    
    di = [ % diagonal indices, used for checking diagonal victories
            1 5 9
            3 5 7
         ];
    
    setup_players
    setup_figure
    
%     switch pc(2)
%         case 1
%             order = {'first','second'};
%         case 2
%             order = {'second','first'};
%     end
%     disp(['Human is playing as ' num_to_letter(pc(1)) ' and moving ' order{1} ])
%     disp(['Computer is playing as ' num_to_letter(cc(1)) ' and moving ' order{2}])

    switch pc(2)
        case 1 % player moves first
            str = {
                    'Human',num_to_letter(pc(1)),'first',...
                    'Computer',num_to_letter(cc(1)),'second'
                  };
        case 2 % CPU moves first
            str = {
                    'Computer',num_to_letter(cc(1)),'first',...
                    'Human',num_to_letter(pc(1)),'second'
                  };
    end
    disp([str{1} ' is playing as ' str{2} ' and moving ' str{3}])
    disp([str{4} ' is playing as ' str{5} ' and moving ' str{6}])
    
    %% Main body
    
    show_board
    while evaluate_board(B) == 0
        wt = whose_turn(B);
        if wt == pc(1)
            take_move % player's turn
        else
            generate_move % CPU's turn
        end
        
        show_board
        
    end
    
    result = evaluate_board(B);
    disp(' ')
    switch result
        case 0
            error('Exited main body, but game seems to be ongoing')
        case {1, 2}
            draw_win_line
            if pc(1) == result
                disp('Human wins')
            else
                disp('Computer wins')
            end
        case 3
            disp('Game ends in a draw')
        otherwise
            error('Game outcome is unrecognized')
    end
    
    
    %% Supporting functions below
    
    function draw_win_line
        % Draws line(s) on the board showing the winning position
        
        for i = 1:3 % for each row and column
            for m = 1:2 % for each marker
                if sum(B(i,:)==m)==3 % row victory
                    switch i % flip vertically
                        case 1
                            y = 3;
                        case 2
                            y = 2;
                        case 3
                            y = 1;
                    end
                    plot([0 1],zeros(1,2)+0.5+(y-2)/3,'LineWidth',lw,'Color',wlc)
                end
                if sum(B(:,i)==m)==3 % column victory
                    plot(zeros(1,2)+0.5+(i-2)/3,[0 1],'LineWidth',lw,'Color',wlc)
                end
            end
        end

        for i = 1:size(di,1) % for each diagonal
            for m = 1:2
                if sum(B(di(i,:))==m)==3
                    switch i
                        case 1 % descending left to right
                            plot([0 1],[1 0],'LineWidth',lw,'Color',wlc)
                        case 2 % ascending left to right
                            plot([0 1],[0 1],'LineWidth',lw,'Color',wlc)
                    end
                end
            end
        end
        
    end
    
    %%
    
    function generate_move
        % Uses random playouts to evaluate candidate moves
        
        disp(' ')
        disp('Computer thinking...')
        
        tic
        E = zeros(3); % evaluation matrix
        os = find(B(:)==0)'; % open spaces
        
        ic = 0; % iteration count
        while toc < ctl % think until time expires

            for i = os % for each open space

                A = B; % copy current game board
                A(i) = cc(1); % pretend to move into open space
                outcome = random_playout(A);

                if outcome == cc(1) % victory for CPU
                    E(i) = E(i)+1;
                elseif outcome == pc(1) % loss for CPU
                    E(i) = E(i)-1;
                end

            end

            ic = ic+1;

            if mod(round(toc*10)/10,0.2)==0 % display the evaluation matrix occasionally
                subplot(2,1,2)
                I = E; % image of computer value function
                I(B>0) = NaN;
                I = I-min(I(:));
                I(I==0) = 1; % prevent division by zero
                I = I/max(I(:));
                I = I*255;
                I(B>0) = -1;
                imshow(I)
                colormap(cm)
                caxis([-1 255])
%                     axis square
                axis equal
                axis off
                drawnow
            end

        end

        E(B>0) = NaN;
        [~,res] = max(E(:));
        
        B(res) = cc(1);
        disp(['Computer plays ' num_to_letter(cc(1)) ' at position ' num2str(res)])% ', ' num2str(ic) ' iterations'])
        
    end

    %%
    
    function res = random_playout(A)
        % Executes a random playout and returns the result
        
        res = evaluate_board(A);
        wt = whose_turn(A);
        while res == 0

            os = find(A==0); % open spaces
            if isempty(os)
                res = evaluate_board(A);
                return
            end
            rm = os(randi([1 length(os)])); % random move
            A(rm) = wt;
            res = evaluate_board(A);
            switch wt % alternate turns
                case 1
                    wt = 2;
                case 2
                    wt = 1;
            end
        end
        
    end

    %%
    
    function res = whose_turn(A)
        % Returns 1 if X's turn, 2 if O's turn
        % Throws an error if board state is invalid
        
        mm = [sum(A(:)==1), sum(A(:)==2)]; % moves made
        if abs(diff(mm))>1
            error('Board state is invalid')
        end
        
        if sum(mm==0) == 2 % no moves made yet
            if pc(2)==1
                res = pc(1);
            else
                res = cc(1);
            end
            return
        end
        
        if mm(1) == mm(2) % if same number of moves for each side
            
            if pc(2) == 1 % if player moves first
                res = pc(1); % it's the player's turn
                return
            else
                res = cc(1); % it's the CPU's turn
            end
            
        else % 
            if mm(1) > mm(2) % X has made more moves
                res = 2;
            else % O has made more moves
                res = 1;
            end
        end
        
    end
    
    %%
    
    function take_move
        % Takes input from the player and updates board state accordingly
        
        subplot(2,1,1)
        disp(' ')
        disp('Awaiting player move...')
        valid = 0;
        while valid == 0
            [x,y] = ginput(1);
            if sum(isnan([x,y]))==0 && sum([x,y]>1)==0 && sum([x,y]<0)==0
                m = discretize([x,y],0:1/3:1);
                res = 3*(m(1)-1) + 4-m(2);
                if B(res)==0
                    valid = 1;
                end
            end
        end
        
        B(res) = pc(1);
        show_board
        disp(['Human plays ' num_to_letter(pc(1)) ' at position ' num2str(res)])
        
    end
    
    %%
    
    function res = evaluate_board(A)
        % Returns 0 if game is ongoing, 1 if X wins, 2 if O wins, 3 if draw
        
        res = 0; % initialize
        for i = 1:3 % for each row and column
            for m = 1:2 % for each marker
                if sum(A(i,:)==m)==3 % row victory
                    res = m;
                    return
                end
                if sum(A(:,i)==m)==3 % column victory
                    res = m;
                    return
                end
            end
        end

        for i = 1:size(di,1) % for each diagonal
            for m = 1:2
                if sum(A(di(i,:))==m)==3
                    res = m;
                    return
                end
            end
        end
        
        if sum(A(:)~=0)==9 % if all spaces filled but no winner
            res = 3; % declare a draw
        end
        
    end
    
    %%
    
    function show_board
        
        h1 = subplot(2,1,1); % board
        cla(h1)
        hold on

        b = linspace(0,1,4); % b for borders
        
        % Show lines
        for i = 2:3
            plot([0 1], [b(i) b(i)],'k','LineWidth',lw) % horizontal
            plot([b(i) b(i)], [0 1],'k','LineWidth',lw) % vertical
        end
        axis([0 1 0 1])

        % Show positions
        x = 1/6 : 2/6 : 5/6;
        [x,y] = meshgrid(x,flipud(x'));
        for i = 1:numel(B)
            switch B(i)
                case 0
                    % Do nothing
                case 1
                    text(x(i),y(i),'X','horizontalalignment','center','verticalalignment','middle','fontsize',ls)
                case 2
                    text(x(i),y(i),'O','horizontalalignment','center','verticalalignment','middle','fontsize',ls)
                otherwise
                    error(['Unrecognized board state at position ' num2str(i) ': "' num2str(B(i)) '"; should be either 0, 1, or 2'])
            end
        end
        
        axis square
        axis equal
        axis off

    end

    %%
    
    function res = num_to_letter(n)
        % Translate player number to player letter
        switch n
            case 1
                res = 'X';
            case 2
                res = 'O';
            otherwise
                error('Invalid input')
        end
    end

    function setup_players
        % Define computer configuration
        switch pc(1)
            case 1
                cc(1) = 2;
            case 2
                cc(1) = 1;
            otherwise
                error('Invalid player configuration')
        end
        switch pc(2)
            case 1
                cc(2) = 2;
            case 2
                cc(2) = 1;
            otherwise
                error('Invalid player configuration')
        end
    end

    function setup_figure
        figure(1)
        clf
        set(gcf,'color','white')

        h1 = subplot(2,1,1);
        cla(h1)
        axis square
        axis equal
        axis off
        
        h2 = subplot(2,1,2);
        cla(h2)
        colormap(cm)
        axis square
        axis equal
        axis off
        
        warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

    end

end



















































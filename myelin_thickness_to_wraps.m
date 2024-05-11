function n = myelin_thickness_to_wraps(tmy, thickness)
    % calculates number of myelin wraps based on myelin thickness
    % assumes a constant plasma membrane thickness of 7.5 nm if none is
    % given

    % Inputs:
    % tmy: myelin thickness in nm
    % thickness: plasma membrane thickness
    
    % Outputs:
    % n: number of myelin wraps

    if nargin == 1
        thickness = 7.5;
    end

    n_dec = tmy / thickness;
    n = round(n_dec); % number of myelin wraps
end


%
% JHU Turbulence Database Matlab client code
%   
% Parse SOAP Response, part of Turbmat
%

%
% Written by:
% 
% Edo Frederix
% The Johns Hopkins University
% Department of Mechanical Engineering
% edofrederix@jhu.edu, edofrederix@gmail.com
%

%
% This file is part of Turbmat.
% 
% Turbmat is free software: you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free
% Software Foundation, either version 3 of the License, or (at your option)
% any later version.
% 
% Turbmat is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
% more details.
% 
% You should have received a copy of the GNU General Public License along
% with Turbmat.  If not, see <http://www.gnu.org/licenses/>.
%

%
% This file replaces the original parseSoapResponse.m function, which
% is very slow. Since we already know the layout of the response, we
% can parse the data much faster
%

function result = turbm_parseSoapResponse( response )

    % See if we have a fault
    errormsg = regexp(char(response), '^.*<soap:Body><soap:Fault>(.*)</soap:Fault></soap:Body>.*$', 'tokens');
    
    if isempty(errormsg)

        % Get all results in body
        tokenStrings = regexp(char(response), '^.*<soap:Body>(?:<[^>]*>){2}(.*)(?:</[^>]*>){2}</soap:Body>.*$', 'tokens');

        body = char(tokenStrings{1});

        items = regexpi(body, '<([a-z][a-z0-9]*)[^>]*>(.*?)<[/]\1>', 'tokens');

        for j = 1:length(items)
            values = regexpi(char(items{j}{2}), '<([a-z][a-z0-9]*)[^>]*>(.*?)<[/]\1>', 'tokens');

            % first cycle: let's preallocate
            if j == 1
                result = zeros(length(values), length(items));
            end

            for i = 1:length(values)
                result(i,j) = str2double(char(values{i}{2}));
            end
        end
        
    else
        
        error('The database threw an error. XML response:\n\n %s\n', char(errormsg{1}));
        
    end
end


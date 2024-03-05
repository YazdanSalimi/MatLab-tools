this function match two tables according to an specific column.
This is what I was using before getting familiar with pd.nerge in python. Reinventing the wheel!
yazdan salimi
salimiyazdan@gmail.com
created on 13.10.2022
function [merged_struct, merged_table, repeated_rows] = match_two_tables(table_referrence, varname_reference, delimiter_reference, selected_redference, table_info,var_name_info,delimiter_info,selected_info,criteria_compare)
try
    struct_reference = table2struct(table_referrence);
    struct_info = table2struct(table_info);
    %info name modification
    list_names_info = {struct_info.(var_name_info)}';
    if isequal(selected_info, "all")
        list_names_info_match = list_names_info;
    else
        for j = 1 : length(list_names_info)
            info_id_name = list_names_info{j};
            if ~isempty(info_id_name)
                if isequal(selected_info, "end")
                    info_id_name_split = strsplit(info_id_name,delimiter_info);
                    info_id_name_match = join(info_id_name_split(end), delimiter_info);
                    list_names_info_match{j,1} = info_id_name_match{1};
                else
                    info_id_name_split = strsplit(info_id_name,delimiter_info);
                    info_id_name_match = join(info_id_name_split(selected_info), delimiter_info);
                    list_names_info_match{j,1} = info_id_name_match{1};
                end
            else
                list_names_info_match{j,1} = 'Thereisnoinformationhere_emptycell_invar_name_info';
            end
        end
    end
    field_names_info_old = fieldnames(struct_info);
    cell_null = cell(size(field_names_info_old));
    cell_null(:,1) = {'not available'};
    for field_info = 1 : length(field_names_info_old)
        field_names_info_new{field_info,1} = char(field_names_info_old{field_info} + "__infosum");
    end

    field_names_ref_old = fieldnames(struct_reference);
    for field_info = 1 : length(field_names_ref_old)
        field_names_ref_new{field_info,1} = char(field_names_ref_old{field_info} + "__ref");
    end

    for i = 1 : length(struct_reference)
        %refernce name selection
        ref_id_name = struct_reference(i).(varname_reference);
        if isequal(selected_redference, "all")
            ref_id_name_match = ref_id_name;
        else
            if ~isequal(ref_id_name, 'not available')
                try
                    if isequal(selected_redference, "end")
                        ref_id_name_split = strsplit(ref_id_name,delimiter_reference);
                        ref_id_name_match = join(ref_id_name_split(end), delimiter_reference);
                        ref_id_name_match = ref_id_name_match{1};
                    else
                        ref_id_name_split = strsplit(ref_id_name,delimiter_reference);
                        ref_id_name_match = join(ref_id_name_split(selected_redference), delimiter_reference);
                        ref_id_name_match = ref_id_name_match{1};
                    end
                catch ME_ref_id_name_match
                    disp("please check the var_name_ref in row:  " + i)
                end
            else
                ref_id_name_match = 'Thereisnoinformationhere_emptycell_invar_name_ref';
            end
        end

        % find the index on info summary file
        if isequal(criteria_compare, "contain")
            struct_info_index = find(contains(string(list_names_info_match), string(ref_id_name_match)));
        elseif isequal(criteria_compare, "match")
            struct_info_index = find(strcmp(string(list_names_info_match), string(ref_id_name_match)));
        else
            disp("criteria_compare can selected as ''contain'' or ''match''")
        end
        if numel(struct_info_index)>1
            warning("there is more than one cases in the info table")
            disp("row: " + i + "    there is more than one cases in the info table")
            repeated_rows(i) = 1;
            struct_info_index = struct_info_index(1);
        end
        % generating final table
        if ~isempty(struct_info_index)
            merged_struct(i,1) = cell2struct([struct2cell(struct_reference(i));struct2cell(struct_info(struct_info_index))],...
                [field_names_ref_new;field_names_info_new]);

        else
            merged_struct(i,1) = cell2struct([struct2cell(struct_reference(i));cell_null],...
                [field_names_ref_new;field_names_info_new]);
        end
    end
    merged_table = struct2table(merged_struct);
catch ME
    if ~isempty(ME.stack)
        disp("there is a problem, check line : " + ME.stack.line)
    else
        disp("there is a problem, check line : " + ME.identifier)
    end
end
end
% the exapmle of running the code
% clear; close all force; clc; fclose all; warning("off", "all")
% %ref
% table_referrence = readtable();
% varname_reference = "";
% delimiter_reference = "-";
% selected_redference = [2,3,4,5,6];
% % info
% table_info = readtable();
% var_name_info = "";
% delimiter_info = "-";
% selected_info = [2,3,4,5,6];
% criteria_compare = "match";
% [merged_struct, merged_table] = match_table_yadan(table_referrence, varname_reference, ...
%     delimiter_reference, selected_redference, ...
%     table_info,var_name_info,delimiter_info,selected_info,criteria_compare);
% 
% writetable(merged_table, "_merged_final.xlsx")
% 


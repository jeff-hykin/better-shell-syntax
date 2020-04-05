require('rubygems')
require('bundler/setup')

require_relative('./grammar.rb')
require_relative('./token_helper.rb')

# TODO
    # use the turnOffNumberedCaptureGroups to disable manual regex groups (which otherwise would completely break the group attributes)
        # add a warning whenever turnOffNumberedCaptureGroups successfully removes a group
    # add a check for newlines inside of regex, and warn the user that newlines will never match
    # add feature inside of oneOrMoreOf() or zeroOrMoreOf()
        # using the tag_as: typically breaks because of repeat
        # so instead, if there is a tag_as:, create an includes section on it that copies the original regex pattern and then tags it
    # add a check that doesnt allow $ in non-special repository names
    # have grammar check at the end to make sure that all of the included repository_names are actually valid repo names
    # add method to append something to all tag names (add an extension: "blah" argument to "to_tag")
    # auto generate a repository entry when a pattern/range is used in more than one place
    # create a way to easily mutate anything on an existing pattern
    # add optimizations
        # add check for seeing if the last pattern was an OR with no attributes. if it was then change (a|(b|c)) to (a|b|c)
        # add a "is alreadly a group" flag to prevent double wrapping

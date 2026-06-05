return {
  ['year'] = function(args, kwargs, meta)
    return pandoc.Str(os.date("%Y"))
  end
}
